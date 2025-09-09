# Custom Python version for Ubuntu images
# Builds python3-apt for specified Python version and sets it as default
ARG BASE_IMAGE
ARG PYTHON_VERSION

# Builder stage - using our base that already has deadsnakes + build tools
FROM ${BASE_IMAGE} AS apt-builder
ARG PYTHON_VERSION

# Install development packages needed for building python3-apt
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libapt-pkg-dev \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        dpkg-dev

# Enable source repositories and build python3-apt for custom Python version
RUN sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    cd /tmp && \
    apt-get source python-apt && \
    cd python-apt-* && \
    python${PYTHON_VERSION} setup.py build && \
    python${PYTHON_VERSION} setup.py install --root=/tmp/apt-install

# Final stage - same base image
FROM ${BASE_IMAGE}
ARG PYTHON_VERSION

# Install the specific Python version (deadsnakes PPA already configured in base)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python${PYTHON_VERSION}

# Set custom Python version as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 100 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 100

# Copy the compiled apt module as last step for maximum cache efficiency
COPY --from=apt-builder /tmp/apt-install /
