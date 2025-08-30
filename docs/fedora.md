# Fedora configuration

This document details the Fedora setup in our ACT runner images, including installed tools,
environment variables, and configuration decisions.

## What's included

### System packages

Fedora images include a comprehensive set of development tools:

- Build essentials (gcc, g++, make, cmake, pkg-config)
- Fedora packaging tools (rpkg, fedora-packager, rpmdevtools)
- Docker (moby-engine) and docker-compose
- GitHub CLI (`gh`)
- Git and Git LFS
- Common utilities (curl, wget, jq, tar, zip)

### Python installation

Images include Fedora's native Python 3 with pip. Python development tools are pre-installed via
[uv](https://github.com/astral-sh/uv):

- [**prek**](https://github.com/kpumuk/prek) - Pre-commit hook runner
- [**ruff**](https://github.com/astral-sh/ruff) - Fast Python linter and formatter
- [**mypy**](https://github.com/python/mypy) - Static type checker
- [**pytest**](https://github.com/pytest-dev/pytest) - Testing framework
- [**black**](https://github.com/psf/black) - Code formatter
- [**isort**](https://github.com/PyCQA/isort) - Import sorter

### Node.js versions

Images include multiple Node.js versions installed in the hostedtoolcache structure, compatible
with [actions/setup-node](https://github.com/actions/setup-node). The specific versions follow
Node.js LTS and current releases.

See the [main README](../README.md#available-images) for current available versions.

### Pre-configured repositories

Repository configurations are included for easy installation of additional tools:

- **GitHub CLI** - Developer tools and utilities
- **Kubernetes** - kubectl and related tools
- **HashiCorp** - Terraform, Vault, Consul
- **Docker CE** - Alternative Docker installation
- **Microsoft** - PowerShell, .NET, Azure CLI

## Environment configuration

The following environment variables are pre-configured:

| Variable | Value | Purpose |
|----------|-------|---------|
| `AGENT_TOOLSDIRECTORY` | `/opt/hostedtoolcache` | Standard location for tools |
| `PATH` | `/root/.local/bin:/root/.cargo/bin:$PATH` | Includes uv, Rust, and installed tools |

## Design decisions

### Why Fedora?

Fedora provides a cutting-edge Linux distribution with:

- Latest development tools and compilers
- Comprehensive RPM packaging ecosystem
- Strong container and cloud-native support
- Regular releases with predictable lifecycle

### Why moby-engine?

We use Fedora's `moby-engine` package instead of Docker CE because:

- Native Fedora packaging and integration
- Consistent multi-architecture support
- Simplified dependency management
- Compatible with Docker CE for all practical purposes

### Image variants

- **fedora-lts**: Fedora 41 with LTS Node.js versions
- **fedora-latest**: Current Fedora with latest Node.js versions
- **fedora-rawhide**: Development branch with latest Node.js versions

## Troubleshooting

### Docker daemon not running

The Docker daemon is not started automatically. Start it with:

```bash
dockerd &
# Or for proper service management
systemctl start docker
```

### Tool not in PATH

All tools should be in PATH, but if not:

```bash
# Check tool installation
uv tool list

# Rust tools
source $HOME/.cargo/env
```

### Need different versions?

For tools not included in our images, use the pre-configured repositories:

```bash
# Install from configured repos
dnf install kubectl terraform gh
```
