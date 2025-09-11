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

# Force non-interactive apt
ENV DEBIAN_FRONTEND=noninteractive

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
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    # Add _apt to root group to handle BuildKit's restrictive umask (027) \
    usermod -a -G root _apt && \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && apt-get install -y --no-install-recommends \
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

# Layer 2: Monthly-update tools (git, security packages, certificates)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    git-lfs \
    gnupg \
    gpg \
    libcairo2 \
    libssl-dev \
    lsb-release \
    openssh-client \
    sudo \
    && apt-get clean

# Layer 3: Docker installation
# Using docker.io package for consistent multi-architecture support
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y --no-install-recommends \
    docker-compose \
    docker.io \
    && apt-get clean \
    && mkdir -p -m 755 /opt/hostedtoolcache

# Layer 4: Node.js installation
ARG NODE_VERSIONS=MUST_PROVIDE_NODE_VERSIONS
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-debian-downloads-${DEBIAN_VERSION}-${TARGETARCH} \
    for VERSION in ${NODE_VERSIONS}; do \
    NODE_URL="https://nodejs.org/dist/latest-v${VERSION}.x/"; \
    NODE_VERSION=$(curl -sL ${NODE_URL} | grep -oP 'node-v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1); \
    FULL_VERSION="v${NODE_VERSION}"; \
    ARCH=$(dpkg --print-architecture | sed 's/amd64/x64/;s/ppc64el/ppc64le/'); \
    TARBALL="/tmp/downloads/node-${FULL_VERSION}-linux-${ARCH}.tar.xz"; \
    if [ ! -f "${TARBALL}" ] || ! xz -t "${TARBALL}" 2>/dev/null; then \
    echo "Downloading Node.js ${FULL_VERSION} for ${ARCH}..."; \
    rm -f "${TARBALL}"; \
    curl -fSL "${NODE_URL}/node-${FULL_VERSION}-linux-${ARCH}.tar.xz" -o "${TARBALL}" || \
    (echo "Failed to download Node.js ${FULL_VERSION} for ${ARCH}" && exit 1); \
    xz -t "${TARBALL}" || (echo "Downloaded file is corrupted" && rm -f "${TARBALL}" && exit 1); \
    fi; \
    NODE_PATH="/opt/hostedtoolcache/node/${NODE_VERSION}/${ARCH}"; \
    mkdir -p "${NODE_PATH}"; \
    echo "Extracting Node.js ${FULL_VERSION} to ${NODE_PATH}..."; \
    tar -xJf "${TARBALL}" --strip-components=1 -C "${NODE_PATH}"; \
    done

# Add newest Node version to PATH
RUN NODE_VERSION=$(ls /opt/hostedtoolcache/node | sort -V | tail -1) && \
    ARCH=$(dpkg --print-architecture | sed 's/amd64/x64/;s/armhf/armv7l/;s/ppc64el/ppc64le/') && \
    echo "export PATH=/opt/hostedtoolcache/node/${NODE_VERSION}/${ARCH}/bin:\$PATH" >> /etc/profile.d/node.sh && \
    ln -sf /opt/hostedtoolcache/node/${NODE_VERSION}/${ARCH}/bin/node /usr/local/bin/node && \
    ln -sf /opt/hostedtoolcache/node/${NODE_VERSION}/${ARCH}/bin/npm /usr/local/bin/npm && \
    ln -sf /opt/hostedtoolcache/node/${NODE_VERSION}/${ARCH}/bin/npx /usr/local/bin/npx

# Layer 5: Python installation (native version only)
# Debian provides native Python - no need for external repositories
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-apt \
    && apt-get clean

# Layer 6: uv, Python tools, and Rust installation
ENV UV_LINK_MODE=copy
ENV PATH="/root/.local/bin:${PATH}"

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked,id=act-debian-uv-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    curl -LsSf https://astral.sh/uv/install.sh | sh \
    && /root/.local/bin/uv tool install prek \
    && /root/.local/bin/uv tool install ruff \
    && /root/.local/bin/uv tool install mypy \
    && /root/.local/bin/uv tool install pytest \
    && /root/.local/bin/uv tool install black \
    && /root/.local/bin/uv tool install isort \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
        sh -s -- -y --no-modify-path --profile minimal --default-toolchain none \
    && echo 'source $HOME/.cargo/env' >> /etc/bash.bashrc

# Layer 7: GitHub CLI installation
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=act-debian-apt-cache-${DEBIAN_VERSION}-${TARGETARCH} \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d && \
    \
    # GitHub CLI repository
    wget -q -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list && \
    \
    # Install GitHub CLI
    apt-get update && apt-get install -y --no-install-recommends gh && \
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
    if [ "${DEBIAN_VERSION}" = "sid" ] || [ "${DEBIAN_VERSION}" = "unstable" ]; then \
      echo "deb [signed-by=/etc/apt/keyrings/llvm-archive-keyring.gpg] \
      http://apt.llvm.org/unstable/ llvm-toolchain main"; \
    else \
      echo "deb [signed-by=/etc/apt/keyrings/llvm-archive-keyring.gpg] \
      http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs) main"; \
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
    if [ "${DEBIAN_VERSION}" != "sid" ] && [ "${DEBIAN_VERSION}" != "unstable" ]; then \
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
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache \
    BUILDKIT_PROGRESS=plain \
    CI=true \
    DOCKER_BUILDKIT=1 \
    DEBIAN_VERSION=${DEBIAN_VERSION} \
    PATH="/root/.local/bin:/root/.cargo/bin:${PATH}"

WORKDIR /tmp

# Verify installations
RUN git --version && \
    (command -v docker >/dev/null 2>&1 && docker --version || echo "Docker not installed") && \
    gh --version && \
    python3 --version && \
    (command -v rustup >/dev/null 2>&1 && rustup --version || echo "Rust not installed") && \
    uv --version && \
    (command -v node >/dev/null 2>&1 && node --version || echo "Node.js not installed") && \
    (command -v npm >/dev/null 2>&1 && npm --version || echo "npm not installed") && \
    # Preload package lists and validate repositories
    apt-get update
