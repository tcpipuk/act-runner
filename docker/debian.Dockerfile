# ACT runner image for Debian with Node.js and Python
ARG DEBIAN_TAG=stable
ARG DEBIAN_VERSION=MUST_PROVIDE_DEBIAN_VERSION
FROM debian:${DEBIAN_TAG} AS base

# Re-declare ARG after FROM
ARG DEBIAN_TAG
ARG DEBIAN_VERSION=MUST_PROVIDE_DEBIAN_VERSION
ARG TARGETARCH

# Set shell options for better error detection
SHELL ["/bin/bash", "-e", "-c"]

# Force non-interactive apt and disable Python bytecode compilation (QEMU workaround)
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1

# Metadata (will be updated with actual versions during build)
LABEL org.opencontainers.image.title="act-runner-debian${DEBIAN_VERSION}" \
    org.opencontainers.image.description="Optimized ACT/Forgejo runner with essential CI tools for Debian ${DEBIAN_VERSION}" \
    org.opencontainers.image.url="https://git.tomfos.tr/tom/act-runner" \
    org.opencontainers.image.source="https://git.tomfos.tr/tom/act-runner" \
    org.opencontainers.image.documentation="https://git.tomfos.tr/tom/act-runner/src/branch/main/README.md" \
    org.opencontainers.image.vendor="git.tomfos.tr" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.authors="Tom Foster"

# Layer 1: Core build tools (rarely change - every few months)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-debian-apt-lists-${DEBIAN_VERSION}-${TARGETARCH} \
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
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-debian-apt-lists-${DEBIAN_VERSION}-${TARGETARCH} \
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
    python3-venv \
    sudo \
    && apt-get clean \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 100

# Layer 3: Docker installation
# Using docker.io package for consistent multi-architecture support
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-debian-apt-lists-${DEBIAN_VERSION}-${TARGETARCH} \
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
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-debian-downloads-${DEBIAN_VERSION}-${TARGETARCH} \
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
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-debian-downloads-${DEBIAN_VERSION}-${TARGETARCH} \
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
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked,id=act-debian-uv-cache-${DEBIAN_VERSION}-${TARGETARCH} \
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
    && if [ "${DEBIAN_TAG}" = "sid" ]; then \
        rustup toolchain install nightly && rustup default nightly; \
    else \
        rustup toolchain install stable && rustup default stable; \
    fi

# Layer 7: GitHub CLI installation
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked,id=act-debian-apt-lists-${DEBIAN_VERSION}-${TARGETARCH} \
    mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d && \
    \
    # GitHub CLI repository
    wget -q -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list && \
    \
    # Install GitHub CLI
    apt-get -qq update && apt-get -qq install -y --no-install-recommends gh yq && \
    apt-get clean

# Layer 8: Configure additional APT repositories for user convenience
# Users can install: clang, kubectl, psql, terraform, etc.
ARG K8S_VERSION=MUST_PROVIDE_K8S_VERSION
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-debian-downloads-${DEBIAN_VERSION}-${TARGETARCH} \
    mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d && \
    \
    # LLVM/Clang - for C/C++ development
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/llvm-archive-keyring.gpg && \
    CODENAME=$(lsb_release -cs) && \
    if [ "${DEBIAN_TAG}" = "sid" ] || [ "${CODENAME}" = "sid" ]; then \
      echo "deb [signed-by=/etc/apt/keyrings/llvm-archive-keyring.gpg] \
      http://apt.llvm.org/unstable/ llvm-toolchain main"; \
    else \
      echo "deb [signed-by=/etc/apt/keyrings/llvm-archive-keyring.gpg] \
      http://apt.llvm.org/${CODENAME}/ llvm-toolchain-${CODENAME} main"; \
    fi > /etc/apt/sources.list.d/llvm.list && \
    \
    # Kubernetes - for k8s operations
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | \
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list && \
    \
    # HashiCorp - for Terraform, Vault, Consul, etc. (skip for sid/unstable)
    if [ "${DEBIAN_TAG}" != "sid" ]; then \
      wget -q -O- https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg && \
      echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/hashicorp.list; \
    fi && \
    \
    # Microsoft ecosystem (PowerShell, .NET, Azure CLI)
    DEBIAN_VERSION_ID=$(lsb_release -rs | cut -d. -f1) && \
    PACKAGE_PATH="/tmp/downloads/packages-microsoft-prod-debian${DEBIAN_VERSION_ID}.deb" && \
    if [ ! -f "${PACKAGE_PATH}" ]; then \
    wget -q https://packages.microsoft.com/config/debian/${DEBIAN_VERSION_ID}/packages-microsoft-prod.deb \
    -O "${PACKAGE_PATH}"; \
    fi && \
    dpkg -i "${PACKAGE_PATH}" && \
    \
    # Ensure all apt keys have correct permissions (safety net)
    chmod 644 /etc/apt/keyrings/*.gpg 2>/dev/null || true

# Set up environment
ENV BUILDKIT_PROGRESS=plain \
    CI=true \
    DOCKER_BUILDKIT=1

WORKDIR /tmp

# Verify installations
RUN git --version && \
    (command -v docker >/dev/null 2>&1 && docker --version || echo "Docker not installed") && \
    gh --version && \
    python3 --version && \
    go version && \
    (command -v rustup >/dev/null 2>&1 && rustup --version || echo "Rust not installed") && \
    uv --version && \
    (command -v node >/dev/null 2>&1 && node --version || echo "Node.js not installed") && \
    (command -v npm >/dev/null 2>&1 && npm --version || echo "npm not installed") && \
    # Preload package lists and validate repositories
    apt-get -qq update
