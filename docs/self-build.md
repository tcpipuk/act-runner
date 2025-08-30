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

The images use a layered architecture where each image builds upon the previous:

1. **Base image** - Ubuntu with essential tools and package repositories
2. **Node image** - Adds Node.js versions to the base image
3. **Python image** - Adds Python and development tools to the Node image

### Build a base image

```bash
docker build -f linux/ubuntu/Dockerfile.base \
  --build-arg UBUNTU_VERSION=24.04 \
  -t act-runner:ubuntu24.04-base \
  ./linux/ubuntu
```

Available Ubuntu versions typically include current LTS releases and the rolling release. Check the
workflow files for the current matrix of supported versions.

### Build a Node.js image

First build the base image, then:

```bash
docker build -f linux/ubuntu/Dockerfile.node \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="20 22" \
  --build-arg BASE_IMAGE=act-runner:ubuntu24.04-base \
  -t act-runner:ubuntu24.04-node20-22 \
  ./linux/ubuntu
```

Node.js versions follow the LTS and current releases from nodejs.org. Multiple versions can be
installed by providing space-separated version numbers.

### Build a Python image

First build the base and Node images, then:

```bash
docker build -f linux/ubuntu/Dockerfile.python \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="20 22" \
  --build-arg PYTHON_VERSION=3.13 \
  --build-arg NODE_IMAGE=act-runner:ubuntu24.04-node20-22 \
  -t act-runner:ubuntu24.04-node20-22-py3.13 \
  ./linux/ubuntu
```

Python versions include the Ubuntu native version and additional versions from the deadsnakes PPA.
Check the workflow files for currently supported versions.

## Build arguments

All Dockerfiles accept these common build arguments:

- `UBUNTU_VERSION` - Ubuntu version to use
- `BUILD_DATE` - Build timestamp (optional)
- `BUILD_VERSION` - Version tag (optional)
- `BUILD_REVISION` - Git commit hash (optional)

Image-specific arguments:

**Dockerfile.base:** No additional required arguments

**Dockerfile.node:**

- `BASE_IMAGE` - The base image to build from
- `NODE_VERSIONS` - Space-separated Node.js versions (e.g. "20 22")

**Dockerfile.python:**

- `NODE_IMAGE` - The Node image to build from
- `NODE_VERSIONS` - Must match the Node image's versions
- `PYTHON_VERSION` - Python version (e.g. 3.13)

## BuildKit features

The Dockerfiles use BuildKit cache mounts for optimal caching:

- APT package cache (`/var/cache/apt`, `/var/lib/apt`)
- Download cache (`/tmp/downloads`)
- Python package cache (`/root/.cache/uv`)

To benefit from these caches, ensure BuildKit is enabled:

```bash
export DOCKER_BUILDKIT=1
```

Or use Docker Buildx:

```bash
docker buildx build -f linux/ubuntu/Dockerfile.base \
  --build-arg UBUNTU_VERSION=24.04 \
  -t act-runner:ubuntu24.04-base \
  ./linux/ubuntu
```

## Multi-architecture builds

To build for multiple architectures (requires Docker Buildx):

```bash
# Create a builder instance
docker buildx create --use

# Build for multiple platforms
docker buildx build -f linux/ubuntu/Dockerfile.base \
  --platform linux/amd64,linux/arm64 \
  --build-arg UBUNTU_VERSION=24.04 \
  -t act-runner:ubuntu24.04-base \
  --push \
  ./linux/ubuntu
```

## Testing your images

With Docker:

```bash
docker run --rm -it act-runner:ubuntu24.04-node20-22-py3.13 bash
```

With ACT:

```bash
act -P ubuntu-latest=act-runner:ubuntu24.04-node20-22-py3.13
```

In GitHub/Forgejo Actions:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: act-runner:ubuntu24.04-node20-22-py3.13
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

1. **Missing base image**: Ensure you build images in order (base → node → python)
2. **Network issues**: Check your internet connection and Docker's DNS settings
3. **Space issues**: Ensure you have enough disk space for Docker images

### Cache issues

If builds aren't using cache as expected:

```bash
# Clear builder cache
docker builder prune

# Force rebuild without cache
docker build --no-cache -f linux/ubuntu/Dockerfile.base \
  --build-arg UBUNTU_VERSION=24.04 \
  -t act-runner:ubuntu24.04-base \
  ./linux/ubuntu
```

## Contributing

When contributing changes:

1. Test your builds locally first
2. Ensure all combinations in the CI matrix still build
3. Update this documentation if you change build processes
4. Follow the existing code style and conventions
