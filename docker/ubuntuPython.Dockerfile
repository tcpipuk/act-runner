# Custom Python version for Ubuntu images
# Builds python3-apt for specified Python version and sets it as default
ARG BASE_IMAGE=MUST_PROVIDE_BASE_IMAGE
ARG PYTHON_VERSION=MUST_PROVIDE_PYTHON_VERSION

# Common Python setup stage
FROM ${BASE_IMAGE} AS python
ARG PYTHON_VERSION=MUST_PROVIDE_PYTHON_VERSION
ARG UBUNTU_VERSION=MUST_PROVIDE_UBUNTU_VERSION
ARG TARGETARCH

# Install Python, venv, set up alternatives, and bootstrap pip
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-ubuntu-apt-lists-${UBUNTU_VERSION}-${TARGETARCH} \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq -o Dpkg::Use-Pty=0 \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-venv && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 100 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 100 && \
    python -m ensurepip

# Builder stage - using common python base
FROM python AS apt-builder

# Install development packages and build python3-apt for custom Python version
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-ubuntu-apt-lists-${UBUNTU_VERSION}-${TARGETARCH} \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq -o Dpkg::Use-Pty=0 \
        libapt-pkg-dev \
        python${PYTHON_VERSION}-dev && \
    cd /tmp && \
    if [ "${UBUNTU_VERSION}" = "22.04" ]; then \
        git clone --depth=1 --branch 2.7.5 https://salsa.debian.org/apt-team/python-apt.git; \
    else \
        git clone --depth=1 https://salsa.debian.org/apt-team/python-apt.git; \
    fi && \
    cd python-apt && \
    python -m pip install --root-user-action=ignore --target /tmp/apt-install/usr/lib/python3/dist-packages .

# Final stage - using common python base
FROM python

# Copy the compiled apt module as last step for maximum cache efficiency
COPY --from=apt-builder /tmp/apt-install /
