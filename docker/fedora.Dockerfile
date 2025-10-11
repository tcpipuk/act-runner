# ACT runner image for Fedora with Node.js and Python
ARG FEDORA_TAG=latest
ARG FEDORA_VERSION=MUST_PROVIDE_FEDORA_VERSION
FROM fedora:${FEDORA_TAG} AS base

# Re-declare ARG after FROM
ARG FEDORA_TAG
ARG FEDORA_VERSION=MUST_PROVIDE_FEDORA_VERSION
ARG TARGETARCH

# Set shell options for better error detection
SHELL ["/bin/bash", "-e", "-c"]

# Metadata
LABEL org.opencontainers.image.title="act-runner-fedora${FEDORA_VERSION}-base" \
    org.opencontainers.image.description="Optimized ACT/Forgejo runner base image with essential CI tools for Fedora ${FEDORA_VERSION}" \
    org.opencontainers.image.url="https://git.tomfos.tr/tom/act-runner" \
    org.opencontainers.image.source="https://git.tomfos.tr/tom/act-runner" \
    org.opencontainers.image.documentation="https://git.tomfos.tr/tom/act-runner/src/branch/main/README.md" \
    org.opencontainers.image.vendor="git.tomfos.tr" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.authors="Tom Foster"

# Layer 1: Core build tools and compression utilities (rarely change - every few months)
RUN --mount=type=cache,target=/var/cache,sharing=locked,id=act-fedora-cache-${FEDORA_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/dnf,sharing=locked,id=act-fedora-dnf-state-${FEDORA_VERSION}-${TARGETARCH} \
    dnf install -yq \
    # Core essentials and build tools (alphabetically sorted)
    cmake \
    fedora-packager \
    file \
    gcc \
    gcc-c++ \
    jq \
    libffi-devel \
    make \
    patch \
    pkg-config \
    procps-ng \
    rpkg \
    rpm-sign \
    rsync \
    unzip \
    wget \
    which \
    zip \
    && dnf clean all \
    && mkdir -p -m 755 /opt/hostedtoolcache

# Layer 2: Monthly-update tools (git, security-sensitive packages, certificates)
RUN --mount=type=cache,target=/var/cache,sharing=locked,id=act-fedora-cache-${FEDORA_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/dnf,sharing=locked,id=act-fedora-dnf-state-${FEDORA_VERSION}-${TARGETARCH} \
    dnf install -yq \
    ca-certificates \
    git \
    git-lfs \
    gnupg2 \
    openssh-clients \
    openssl-devel \
    python3 \
    python3-pip \
    sudo \
    && dnf clean all \
    && alternatives --install /usr/bin/python python /usr/bin/python3 100

# Layer 3: Docker (using moby-engine for consistent multi-arch support)
RUN --mount=type=cache,target=/var/cache,sharing=locked,id=act-fedora-cache-${FEDORA_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/dnf,sharing=locked,id=act-fedora-dnf-state-${FEDORA_VERSION}-${TARGETARCH} \
    dnf install -yq \
    moby-engine \
    docker-compose \
    && dnf clean all \
    && systemctl disable docker.service docker.socket || true

# Set up environment paths and uv configuration
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache \
    UV_LINK_MODE=copy \
    UV_NO_PROGRESS=true \
    PATH="/root/.local/bin:/root/.cargo/bin:${PATH}"

# Layer 4: Node.js installation
ARG NODE_VERSION=MUST_PROVIDE_NODE_VERSION
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-fedora-downloads-${FEDORA_VERSION}-${TARGETARCH} \
    NODE_URL="https://nodejs.org/dist/latest-v${NODE_VERSION}.x/" && \
    FULL_NODE_VERSION=$(curl -sL ${NODE_URL} | grep -oP 'node-v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1) && \
    FULL_VERSION="v${FULL_NODE_VERSION}" && \
    ARCH=$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/;s/ppc64le/ppc64le/') && \
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

# Layer 4.5: Go installation
ARG GO_VERSION=MUST_PROVIDE_GO_VERSION
RUN --mount=type=cache,target=/tmp/downloads,sharing=locked,id=act-fedora-downloads-${FEDORA_VERSION}-${TARGETARCH} \
    ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') && \
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

# Layer 5: uv, Python tools, and Rust installation
RUN --mount=type=cache,target=/var/cache,sharing=locked,id=act-fedora-cache-${FEDORA_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/dnf,sharing=locked,id=act-fedora-dnf-state-${FEDORA_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/root/.cache/uv,sharing=locked,id=act-fedora-uv-cache-${FEDORA_VERSION}-${TARGETARCH} \
    curl -LsSf https://astral.sh/uv/install.sh | sh \
    && uv tool install prek \
    && uv tool install ruff \
    && uv tool install mypy \
    && uv tool install pytest \
    && uv tool install black \
    && uv tool install isort \
    && dnf install -yq rustup \
    && dnf clean all \
    && rustup-init -y --no-modify-path --profile minimal --default-toolchain none \
    && echo 'source $HOME/.cargo/env' >> /etc/bashrc \
    && . "$HOME/.cargo/env" \
    && if [ "${FEDORA_TAG}" = "rawhide" ]; then \
        rustup toolchain install nightly && rustup default nightly; \
    else \
        rustup toolchain install stable && rustup default stable; \
    fi

# Layer 6: GitHub CLI installation
RUN --mount=type=cache,target=/var/cache,sharing=locked,id=act-fedora-cache-${FEDORA_VERSION}-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/dnf,sharing=locked,id=act-fedora-dnf-state-${FEDORA_VERSION}-${TARGETARCH} \
    dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf install -yq gh yq && dnf clean all

# Layer 7: Optional repositories for user convenience
# Users can install: kubectl, terraform, docker-ce, dotnet, powershell, azure-cli, etc.
ARG K8S_VERSION=MUST_PROVIDE_K8S_VERSION
RUN mkdir -p /etc/yum.repos.d && \
    \
    # Kubernetes
    echo '[kubernetes]' > /etc/yum.repos.d/kubernetes.repo && \
    echo 'name=Kubernetes' >> /etc/yum.repos.d/kubernetes.repo && \
    echo "baseurl=https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/rpm/" >> /etc/yum.repos.d/kubernetes.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/kubernetes.repo && \
    echo 'gpgcheck=1' >> /etc/yum.repos.d/kubernetes.repo && \
    echo "gpgkey=https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/rpm/repodata/repomd.xml.key" >> /etc/yum.repos.d/kubernetes.repo && \
    \
    # HashiCorp (Terraform, Vault, Consul, etc.)
    dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    \
    # Docker CE
    dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo && \
    \
    # Microsoft ecosystem (PowerShell, .NET, Azure CLI)
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo '[packages-microsoft-prod]' > /etc/yum.repos.d/microsoft.repo && \
    echo 'name=Microsoft packages' >> /etc/yum.repos.d/microsoft.repo && \
    echo 'baseurl=https://packages.microsoft.com/fedora/$releasever/prod/' >> /etc/yum.repos.d/microsoft.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/microsoft.repo && \
    echo 'gpgcheck=1' >> /etc/yum.repos.d/microsoft.repo && \
    echo 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' >> /etc/yum.repos.d/microsoft.repo

WORKDIR /tmp

# Verify installations
RUN git --version && \
    docker --version && \
    gh --version && \
    python3 --version && \
    go version && \
    rustup --version && \
    uv --version && \
    (command -v node >/dev/null 2>&1 && node --version || echo "Node.js not installed") && \
    (command -v npm >/dev/null 2>&1 && npm --version || echo "npm not installed") && \
    # Preload package lists and validate repositories
    dnf makecache
