# Python Configuration

This document details the Python setup in our ACT runner images, including installed tools,
environment variables, and configuration decisions.

## Python Versions

We provide Python 3.11 and 3.13 across our Ubuntu versions:

- **Ubuntu 22.04 & 24.04**: Python 3.11 and 3.13 via [deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa)
- **Ubuntu 25.04**: Python 3.13 only (from system packages)

## Pre-installed Python Tools

All Python images come with these development tools pre-installed via [uv](https://github.com/astral-sh/uv):

- [**prek**](https://github.com/kpumuk/prek) - Pre-commit hook runner
- [**ruff**](https://github.com/astral-sh/ruff) - Fast Python linter and formatter
- [**mypy**](https://github.com/python/mypy) - Static type checker
- [**pytest**](https://github.com/pytest-dev/pytest) - Testing framework
- [**black**](https://github.com/psf/black) - Code formatter
- [**isort**](https://github.com/PyCQA/isort) - Import sorter

## Environment Variables

The following environment variables are pre-configured:

| Variable | Value | Purpose |
|----------|-------|---------|
| `UV_PYTHON` | `python{version}` | Tells uv which Python to use |
| `UV_LINK_MODE` | `copy` | Reduces verbosity in CI logs |
| `PATH` | `/root/.local/bin:$PATH` | Includes uv and installed tools |

## PATH Configuration

The PATH includes `/root/.local/bin` to ensure:

- `uv` itself is available
- Tools installed via `uv tool install` are accessible
- No warnings about PATH during tool installation

## Package Management

### System Packages

Each Python installation includes:

- `python{version}` - The Python interpreter
- `python{version}-dev` - Development headers for building extensions
- `python{version}-venv` - Virtual environment support

### Missing Packages

We deliberately exclude:

- `python-distutils` - Deprecated since Python 3.10, removed in 3.12+

If you need distutils for legacy code, you can install it:

```bash
# Ubuntu 22.04/24.04 (from deadsnakes PPA)
apt-get update && apt-get install -y python3.11-distutils

# Note: Not available for Python 3.13 as distutils was removed
```

## Tool Management

All Python tools are managed via uv and can be updated or removed:

```bash
# Update a tool
uv tool update ruff

# Install additional tools
uv tool install poetry
uv tool install pipenv

# Remove a tool
uv tool remove black

# List installed tools
uv tool list
```

## Virtual Environments

Python virtual environment support is built-in:

```bash
# Create a virtual environment
python -m venv .venv

# Or use uv for faster venv creation
uv venv

# Activate it
source .venv/bin/activate
```

## Available Python Versions by Image

| Ubuntu | Python 3.11 | Python 3.13 |
|--------|-------------|-------------|
| 22.04 | ✅ | ✅ |
| 24.04 | ✅ | ✅ |
| 25.04 | ❌ | ✅ |

## Design Decisions

### Why uv?

We use [uv](https://github.com/astral-sh/uv) as our Python package installer because:

- It's 10-100x faster than pip
- Provides consistent tool management via `uv tool`
- Reduces CI build times significantly
- Maintained by the Ruff team (Astral)

### Why these specific tools?

The pre-installed tools cover the most common Python development needs:

- **Linting & Formatting**: ruff, black, isort
- **Type Checking**: mypy
- **Testing**: pytest
- **Pre-commit**: prek

This provides a complete Python development environment out of the box while keeping the
image size reasonable.

### Why no distutils?

Python's `distutils` was deprecated in Python 3.10 and removed entirely in Python 3.12. Most
modern Python packages have migrated to `setuptools` or other build systems. We exclude it to:

- Keep images smaller
- Encourage modern packaging practices
- Avoid confusion with deprecated APIs

### Why deadsnakes PPA?

The [deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa) provides:

- Newer Python versions on older Ubuntu releases
- Consistent Python packaging across Ubuntu versions
- Regular security updates
- Minimal overhead (only adds package repository)

## Troubleshooting

### Module Not Found

If you encounter import errors for standard library modules:

```bash
# Ensure you're using the right Python
which python
python --version

# For virtual environments, check activation
echo $VIRTUAL_ENV
```

### Tool Not in PATH

All tools should be in PATH, but if not:

```bash
# Check tool installation
uv tool list

# Manually add to PATH if needed
export PATH="/root/.local/bin:$PATH"
```

### Need a Different Python Version?

If you need a Python version not included in our images, use the
[actions/setup-python](https://github.com/actions/setup-python) action in your workflow. It
supports all Python versions and includes built-in caching options.
