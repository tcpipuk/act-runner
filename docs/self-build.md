# Building ACT runner images locally

This guide explains how to build your own ACT runner images locally for testing or customisation.

## Prerequisites

You'll need Docker installed and running on your system. Follow the official [Docker Engine
Installation Guide](https://docs.docker.com/engine/install/) for your platform. Docker BuildKit
should be enabled (it's the default in modern Docker versions).

Clone the repository:

```bash
git clone https://git.tomfos.tr/tom/act-runner.git
cd act-runner
```

## Building images

The images are now built in a single step with all components (Ubuntu/Fedora + Node.js + Python) included:

### Build Ubuntu images

```bash
docker build -f docker/ubuntu.Dockerfile \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="22 24" \
  --build-arg PYTHON_VERSION=3.13 \
  -t act-runner:ubuntu24.04-node22-24-py3.13 \
  ./docker
```

For native Python instead of deadsnakes:

```bash
docker build -f docker/ubuntu.Dockerfile \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="22 24" \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg USE_NATIVE_PYTHON=true \
  -t act-runner:ubuntu24.04-node22-24-py3.12 \
  ./docker
```

### Build Fedora images

```bash
docker build -f docker/fedora.Dockerfile \
  --build-arg FEDORA_VERSION=42 \
  --build-arg NODE_VERSIONS="22 24" \
  -t act-runner:fedora42-node22-24-py3.13 \
  ./docker
```

Available versions typically include current LTS releases and the rolling/rawhide release. Check the
workflow files for the current matrix of supported versions.

## Build arguments

**Ubuntu Dockerfile (`docker/ubuntu.Dockerfile`):**

- `UBUNTU_VERSION` - Ubuntu version to use (e.g. "24.04")
- `NODE_VERSIONS` - Space-separated Node.js versions (e.g. "22 24")
- `PYTHON_VERSION` - Python version (e.g. "3.13")
- `USE_NATIVE_PYTHON` - Set to "true" to use native Ubuntu Python instead of deadsnakes
- `K8S_VERSION` - Kubernetes version for repository setup (e.g. "1.31")

**Fedora Dockerfile (`docker/fedora.Dockerfile`):**

- `FEDORA_VERSION` - Fedora version to use (e.g. "42" or "rawhide")
- `NODE_VERSIONS` - Space-separated Node.js versions (e.g. "22 24")
- `K8S_VERSION` - Kubernetes version for repository setup (e.g. "1.31")

## BuildKit features

The Dockerfiles use BuildKit cache mounts for optimal caching:

- APT/DNF package cache (`/var/cache/apt`, `/var/lib/apt` for Ubuntu; `/var/cache/dnf`,
  `/var/lib/dnf` for Fedora)
- Download cache (`/tmp/downloads`)
- Python package cache (`/root/.cache/uv`)

To benefit from these caches, ensure BuildKit is enabled:

```bash
export DOCKER_BUILDKIT=1
```

Or use Docker Buildx:

```bash
docker buildx build -f docker/ubuntu.Dockerfile \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="22 24" \
  --build-arg PYTHON_VERSION=3.13 \
  -t act-runner:ubuntu24.04-node22-24-py3.13 \
  ./docker
```

## Multi-architecture builds

To build for multiple architectures (requires Docker Buildx):

```bash
# Create a builder instance
docker buildx create --use

# Build for multiple platforms
docker buildx build -f docker/ubuntu.Dockerfile \
  --platform linux/amd64,linux/arm64,linux/ppc64le,linux/s390x \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="22 24" \
  --build-arg PYTHON_VERSION=3.13 \
  -t act-runner:ubuntu24.04-node22-24-py3.13 \
  --push \
  ./docker
```

## Testing your images

With Docker:

```bash
docker run --rm -it act-runner:ubuntu24.04-node22-24-py3.13 bash
```

With ACT:

```bash
act -P ubuntu-latest=act-runner:ubuntu24.04-node22-24-py3.13
```

In GitHub/Forgejo Actions:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: act-runner:ubuntu24.04-node22-24-py3.13
    steps:
      - uses: actions/checkout@v4
      - run: python --version
      - run: node --version
```

## Customisation tips

To add system packages, edit the appropriate Dockerfile and add packages to the `apt-get install`
command. Remember to:

- Keep packages alphabetically sorted for maintainability
- Use `--no-install-recommends` to minimise image size
- Clear apt lists with `rm -rf /var/lib/apt/lists/*`

To change tool versions:

- **Node.js**: Modify `NODE_VERSIONS` build argument
- **Python**: Modify `PYTHON_VERSION` build argument
- **Ubuntu**: Modify `UBUNTU_VERSION` build argument

For tools that should be available in all images, add them to `Dockerfile.base`. For
language-specific tools, add them to the appropriate Dockerfile.

## Troubleshooting

### Build failures

1. **Network issues**: Check your internet connection and Docker's DNS settings
2. **Space issues**: Ensure you have enough disk space for Docker images
3. **BuildKit not enabled**: Ensure Docker BuildKit is enabled (`export DOCKER_BUILDKIT=1`)

### Cache issues

If builds aren't using cache as expected:

```bash
# Clear builder cache
docker builder prune

# Force rebuild without cache
docker build --no-cache -f docker/ubuntu.Dockerfile \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="22 24" \
  --build-arg PYTHON_VERSION=3.13 \
  -t act-runner:ubuntu24.04-node22-24-py3.13 \
  ./docker
```

## Contributing

When contributing changes:

1. Test your builds locally first
2. Ensure all combinations in the CI matrix still build
3. Update this documentation if you change build processes
4. Follow the existing code style and conventions
