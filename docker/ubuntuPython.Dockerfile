# Custom Python version for Ubuntu images
# Builds python3-apt for specified Python version and sets it as default
ARG BASE_IMAGE=MUST_PROVIDE_BASE_IMAGE
ARG PYTHON_VERSION=MUST_PROVIDE_PYTHON_VERSION

# Builder stage - using our base that already has deadsnakes + build tools
FROM ${BASE_IMAGE} AS apt-builder
ARG PYTHON_VERSION=MUST_PROVIDE_PYTHON_VERSION
ARG UBUNTU_VERSION=MUST_PROVIDE_UBUNTU_VERSION
ARG TARGETARCH

# Install development packages needed for building python3-apt
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libapt-pkg-dev \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        dpkg-dev

# Enable source repositories and build python3-apt for custom Python version
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    cd /tmp && \
    apt-get source python-apt && \
    cd python-apt-* && \
    python${PYTHON_VERSION} setup.py build && \
    python${PYTHON_VERSION} setup.py install --root=/tmp/apt-install

# Final stage - same base image
FROM ${BASE_IMAGE}
ARG PYTHON_VERSION=MUST_PROVIDE_PYTHON_VERSION
ARG UBUNTU_VERSION=MUST_PROVIDE_UBUNTU_VERSION
ARG TARGETARCH

# Install the specific Python version (deadsnakes PPA already configured in base)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python${PYTHON_VERSION}

# Set custom Python version as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 100 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 100

# Copy the compiled apt module as last step for maximum cache efficiency
COPY --from=apt-builder /tmp/apt-install /
