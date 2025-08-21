# Building ACT Runner Images Locally

This guide explains how to build your own ACT runner images locally for testing or customisation.

## Prerequisites

### Docker Installation

You'll need Docker installed and running on your system. Follow the official Docker installation
guide for your platform:

- [Docker Engine Installation Guide](https://docs.docker.com/engine/install/)
- Ensure Docker BuildKit is enabled (it's the default in modern Docker versions)

### Repository Setup

Clone the repository:

```bash
git clone https://git.tomfos.tr/tom/act-runner.git
cd act-runner
```

## Building Images

The images use a layered architecture where each image builds upon the previous:

1. **Base image** - Ubuntu with essential tools and package repositories
2. **Node image** - Adds Node.js versions to the base image
3. **Python image** - Adds Python and development tools to the Node image

### Build a Base Image

```bash
docker build -f linux/ubuntu/Dockerfile.base \
  --build-arg UBUNTU_VERSION=24.04 \
  -t act-runner:ubuntu24.04-base \
  ./linux/ubuntu
```

Available Ubuntu versions:

- `22.04` - Ubuntu 22.04 LTS (Jammy)
- `24.04` - Ubuntu 24.04 LTS (Noble)
- `25.04` - Ubuntu 25.04 (Plucky)

### Build a Node.js Image

First build the base image, then:

```bash
docker build -f linux/ubuntu/Dockerfile.node \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg NODE_VERSIONS="20 22" \
  --build-arg BASE_IMAGE=act-runner:ubuntu24.04-base \
  -t act-runner:ubuntu24.04-node20-22 \
  ./linux/ubuntu
```

Available Node.js version combinations:

- `"18 20"` - Node.js 18 and 20
- `"20 22"` - Node.js 20 and 22
- `"22 24"` - Node.js 22 and 24

### Build a Python Image

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

Available Python versions:

- `3.10`, `3.11`, `3.12`, `3.13`, `3.14`

## Build Arguments

### Common Arguments

All Dockerfiles accept these build arguments:

- `UBUNTU_VERSION` - Ubuntu version (22.04, 24.04, 25.04)
- `BUILD_DATE` - Build timestamp (optional)
- `BUILD_VERSION` - Version tag (optional)
- `BUILD_REVISION` - Git commit hash (optional)

### Image-Specific Arguments

**Dockerfile.base:**

- No additional required arguments

**Dockerfile.node:**

- `BASE_IMAGE` - The base image to build from
- `NODE_VERSIONS` - Space-separated Node.js versions (e.g., "20 22")

**Dockerfile.python:**

- `NODE_IMAGE` - The Node image to build from
- `NODE_VERSIONS` - Must match the Node image's versions
- `PYTHON_VERSION` - Python version (e.g., 3.13)

## BuildKit Features

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

## Multi-Architecture Builds

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

## Testing Your Images

### With Docker

```bash
docker run --rm -it act-runner:ubuntu24.04-node20-22-py3.13 bash
```

### With ACT

```bash
act -P ubuntu-latest=act-runner:ubuntu24.04-node20-22-py3.13
```

### In GitHub/Forgejo Actions

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

## Customisation Tips

### Adding System Packages

Edit the appropriate Dockerfile and add packages to the `apt-get install` command. Remember to:

- Keep packages alphabetically sorted for maintainability
- Use `--no-install-recommends` to minimise image size
- Clear apt lists with `rm -rf /var/lib/apt/lists/*`

### Changing Tool Versions

- **Node.js**: Modify `NODE_VERSIONS` build argument
- **Python**: Modify `PYTHON_VERSION` build argument
- **Ubuntu**: Modify `UBUNTU_VERSION` build argument

### Adding New Tools

For tools that should be available in all images, add them to `Dockerfile.base`.
For language-specific tools, add them to the appropriate Dockerfile.

## Troubleshooting

### Build Failures

1. **Missing base image**: Ensure you build images in order (base → node → python)
2. **Network issues**: Check your internet connection and Docker's DNS settings
3. **Space issues**: Ensure you have enough disk space for Docker images

### Cache Issues

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
