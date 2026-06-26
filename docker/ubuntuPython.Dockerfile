# Custom Python version for Ubuntu images
# Builds python3-apt only when the requested Python differs from the distro default
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
    apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-venv && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 100 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 100 && \
    python -m ensurepip

# Builder stage - using common python base
FROM python AS apt-builder

# Build python3-apt for the requested Python — but only when it isn't already the
# distro default. When the requested version matches native python3, the distro's
# own python3-apt already targets it (installed in the base image), so there is
# nothing to build and /tmp/apt-install is left empty for a no-op COPY downstream.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-ubuntu-apt-lists-${UBUNTU_VERSION}-${TARGETARCH} \
    apt-get -qq update && \
    mkdir -p /tmp/apt-install && \
    NATIVE_PYTHON=$(apt-cache show python3 | grep '^Version:' | head -1 | cut -d' ' -f2 | cut -d. -f1-2) && \
    if [ "${PYTHON_VERSION}" = "${NATIVE_PYTHON}" ]; then \
        echo "Python ${PYTHON_VERSION} is the distro default (${NATIVE_PYTHON}) — native python3-apt already targets it, nothing to build"; \
    else \
        DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
            libapt-pkg-dev \
            python${PYTHON_VERSION}-dev && \
        cd /tmp && \
        if [ "${UBUNTU_VERSION}" = "22.04" ]; then \
            git clone --depth=1 --branch 2.7.5 https://salsa.debian.org/apt-team/python-apt.git; \
        else \
            git clone --depth=1 https://salsa.debian.org/apt-team/python-apt.git; \
        fi && \
        cd python-apt && \
        python -m pip install --root-user-action=ignore --target /tmp/apt-install/usr/lib/python3/dist-packages .; \
    fi

# Final stage - using common python base
FROM python

# Copy the compiled apt module as last step for maximum cache efficiency
COPY --from=apt-builder /tmp/apt-install /
