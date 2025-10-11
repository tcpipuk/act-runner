# ACT runner image for Ubuntu with Node.js and Python
ARG UBUNTU_TAG=latest
ARG UBUNTU_VERSION=MUST_PROVIDE_UBUNTU_VERSION
FROM ubuntu:${UBUNTU_TAG} AS base

# Re-declare ARG after FROM
ARG UBUNTU_TAG
ARG UBUNTU_VERSION
ARG TARGETARCH

# Set shell options for better error detection
SHELL ["/bin/bash", "-e", "-c"]

# Force non-interactive apt
ENV DEBIAN_FRONTEND=noninteractive

# Metadata (will be updated with actual versions during build)
LABEL org.opencontainers.image.title="act-runner-ubuntu${UBUNTU_VERSION}" \
    org.opencontainers.image.description="Optimized ACT/Forgejo runner with essential CI tools for Ubuntu ${UBUNTU_VERSION}" \
    org.opencontainers.image.url="https://git.tomfos.tr/tom/act-runner" \
    org.opencontainers.image.source="https://git.tomfos.tr/tom/act-runner" \
    org.opencontainers.image.documentation="https://git.tomfos.tr/tom/act-runner/src/branch/main/README.md" \
    org.opencontainers.image.vendor="git.tomfos.tr" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.authors="Tom Foster"

# Layer 1: Core build tools (rarely change - every few months)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-ubuntu-apt-lists-${UBUNTU_VERSION}-${TARGETARCH} \
    # Configure APT for containerised builds \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/00docker-buildkit && \
    echo 'Dpkg::Use-Pty "0";' >> /etc/apt/apt.conf.d/00docker-buildkit && \
    apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    # Build tools and compression utilities (alphabetically sorted)
    apt-utils \
    build-essential \
    bzip2 \
    cmake \
    curl \
    file \
    g++ \
    gcc \
    gzip \
    jq \
    libffi-dev \
    make \
    patch \
    pkg-config \
    rsync \
    tar \
    unzip \
    wget \
    xz-utils \
    zip \
    && apt-get clean

# Layer 2: System essentials with Python (required for package management)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-ubuntu-apt-lists-${UBUNTU_VERSION}-${TARGETARCH} \
    apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    ca-certificates \
    git \
    git-lfs \
    gnupg \
    gpg \
    libcairo2 \
    libssl-dev \
    lsb-release \
    openssh-client \
    python3 \
    python3-apt \
    python3-setuptools \
    python3-software-properties \
    python3-venv \
    software-properties-common \
    sudo \
    && apt-get clean \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 100

# Layer 3: Docker installation
# Using docker.io package for consistent multi-architecture support
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-ubuntu-apt-lists-${UBUNTU_VERSION}-${TARGETARCH} \
    apt-get -qq update && apt-get -qq install -y --no-install-recommends \
    docker-compose \
    docker.io \
    && apt-get clean \
    && mkdir -p -m 755 /opt/hostedtoolcache

# Set up environment paths and uv configuration
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache \
    UV_LINK_MODE=copy \
    UV_NO_PROGRESS=true \
    PATH="/root/.local/bin:/root/.cargo/bin:${PATH}"

# Layer 4: Node.js installation
ARG NODE_VERSION=MUST_PROVIDE_NODE_VERSION
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-ubuntu-downloads-${UBUNTU_VERSION}-${TARGETARCH} \
    NODE_URL="https://nodejs.org/dist/latest-v${NODE_VERSION}.x/" && \
    FULL_NODE_VERSION=$(curl -sL ${NODE_URL} | grep -oP 'node-v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
    FULL_VERSION="v${FULL_NODE_VERSION}" && \
    ARCH=$(dpkg --print-architecture | sed 's/amd64/x64/;s/ppc64el/ppc64le/') && \
    TARBALL="/tmp/downloads/node-${FULL_VERSION}-linux-${ARCH}.tar.xz" && \
    if [ ! -f "${TARBALL}" ] || ! xz -t "${TARBALL}" 2>/dev/null; then \
        echo "Downloading Node.js ${FULL_VERSION} for ${ARCH}..." && \
        rm -f "${TARBALL}" && \
        curl -fSL "${NODE_URL}/node-${FULL_VERSION}-linux-${ARCH}.tar.xz" -o "${TARBALL}" || \
            (echo "Failed to download Node.js ${FULL_VERSION} for ${ARCH}" && exit 1) && \
        xz -t "${TARBALL}" || (echo "Downloaded file is corrupted" && rm -f "${TARBALL}" && exit 1); \
    fi && \
    NODE_PATH="/opt/hostedtoolcache/node/${FULL_NODE_VERSION}/${ARCH}" && \
    mkdir -p "${NODE_PATH}" && \
    echo "Extracting Node.js ${FULL_VERSION} to ${NODE_PATH}..." && \
    tar -xJf "${TARBALL}" --strip-components=1 -C "${NODE_PATH}" && \
    echo "export PATH=${NODE_PATH}/bin:\$PATH" >> /etc/profile.d/node.sh && \
    ln -sf ${NODE_PATH}/bin/node /usr/local/bin/node && \
    ln -sf ${NODE_PATH}/bin/npm /usr/local/bin/npm && \
    ln -sf ${NODE_PATH}/bin/npx /usr/local/bin/npx

# Layer 5: Go installation
ARG GO_VERSION=MUST_PROVIDE_GO_VERSION
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-ubuntu-downloads-${UBUNTU_VERSION}-${TARGETARCH} \
    ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
        ppc64el) ARCH=ppc64le ;; \
    esac && \
    TARBALL="/tmp/downloads/go${GO_VERSION}.linux-${ARCH}.tar.gz" && \
    if [ ! -f "${TARBALL}" ] || ! gzip -t "${TARBALL}" 2>/dev/null; then \
        echo "Downloading Go ${GO_VERSION} for ${ARCH}..." && \
        rm -f "${TARBALL}" && \
        curl -fSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o "${TARBALL}" || \
            (echo "Failed to download Go ${GO_VERSION} for ${ARCH}" && exit 1) && \
        gzip -t "${TARBALL}" || (echo "Downloaded file is corrupted" && rm -f "${TARBALL}" && exit 1); \
    fi && \
    echo "Extracting Go ${GO_VERSION}..." && \
    tar -xzf "${TARBALL}" -C /usr/local && \
    ln -sf /usr/local/go/bin/* /usr/local/bin/

# Layer 6: uv, Python tools, and Rust installation
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked,id=act-ubuntu-uv-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    curl -LsSf https://astral.sh/uv/install.sh | sh \
    && uv tool install prek \
    && uv tool install ruff \
    && uv tool install mypy \
    && uv tool install pytest \
    && uv tool install black \
    && uv tool install isort \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
        sh -s -- -y --no-modify-path --profile minimal --default-toolchain none \
    && echo 'source $HOME/.cargo/env' >> /etc/bash.bashrc \
    && . "$HOME/.cargo/env" \
    && if [ "${UBUNTU_TAG}" = "rolling" ]; then \
        rustup toolchain install nightly && rustup default nightly; \
    else \
        rustup toolchain install stable && rustup default stable; \
    fi

# Layer 7: GitHub CLI installation
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-ubuntu-apt-cache-${UBUNTU_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-ubuntu-apt-lists-${UBUNTU_VERSION}-${TARGETARCH} \
    mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d && \
    \
    # GitHub CLI repository
    wget -q -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list && \
    \
    # Install GitHub CLI and yq (conditional for Ubuntu version)
    apt-get -qq update && \
    if apt-cache show yq >/dev/null 2>&1; then \
        # Ubuntu 24+ has yq in repositories
        apt-get -qq install -y --no-install-recommends gh yq; \
    else \
        # Ubuntu 22.04 - install gh and download yq binary
        apt-get -qq install -y --no-install-recommends gh && \
        YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep -o '"tag_name": "v[^"]*"' | cut -d'"' -f4) && \
        case "${TARGETARCH}" in \
            amd64) YQ_ARCH="amd64" ;; \
            arm64) YQ_ARCH="arm64" ;; \
            ppc64le) YQ_ARCH="ppc64le" ;; \
            s390x) YQ_ARCH="s390x" ;; \
            *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
        esac && \
        curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${YQ_ARCH}" -o /usr/local/bin/yq && \
        chmod +x /usr/local/bin/yq; \
    fi && \
    apt-get clean

# Layer 8: Configure additional APT repositories for user convenience
# Users can install: clang, kubectl, psql, terraform, etc.
ARG K8S_VERSION=MUST_PROVIDE_K8S_VERSION
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-ubuntu-downloads-${UBUNTU_VERSION}-${TARGETARCH} \
    mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d && \
    \
    # Deadsnakes PPA - for newer Python versions (skip for rolling release)
    if [ "${UBUNTU_TAG}" != "rolling" ]; then \
        add-apt-repository ppa:deadsnakes/ppa -y; \
    fi && \
    \
    # LLVM/Clang - for C/C++ development
    CODENAME=$(lsb_release -cs) && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/llvm-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/llvm-archive-keyring.gpg] \
    https://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME} main" \
    > /etc/apt/sources.list.d/llvm.list && \
    \
    # Kubernetes - for k8s operations
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | \
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list && \
    \
    # HashiCorp - for Terraform, Vault, Consul, etc.
    wget -q -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list && \
    \
    # Microsoft ecosystem (PowerShell, .NET, Azure CLI)
    PACKAGE_PATH="/tmp/downloads/packages-microsoft-prod-$(lsb_release -rs).deb" && \
    if [ ! -f "${PACKAGE_PATH}" ]; then \
    wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb \
    -O "${PACKAGE_PATH}"; \
    fi && \
    dpkg -i "${PACKAGE_PATH}" && \
    \
    # Ensure all apt keys have correct permissions (safety net)
    chmod 644 /etc/apt/keyrings/*.gpg 2>/dev/null || true && \
    apt-get clean

# Set up environment
ENV BUILDKIT_PROGRESS=plain \
    CI=true \
    DOCKER_BUILDKIT=1

WORKDIR /tmp

# Verify installations
RUN git --version && \
    docker --version && \
    gh --version && \
    python3 --version && \
    go version && \
    (command -v rustup >/dev/null 2>&1 && rustup --version || echo "Rust not installed") && \
    uv --version && \
    (command -v node >/dev/null 2>&1 && node --version || echo "Node.js not installed") && \
    (command -v npm >/dev/null 2>&1 && npm --version || echo "npm not installed") && \
    # Preload package lists and validate repositories
    apt-get -qq update
