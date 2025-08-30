# Python configuration

This document details the Python setup in our ACT runner images, including installed tools,
environment variables, and configuration decisions.

## What's included

### Python installations

Images include either the Ubuntu distribution's native Python or additional versions from the
[deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa). The native Python version
varies by Ubuntu release and includes `python3-apt` for system package compatibility.

Each Python installation includes:

- `python{version}` - The Python interpreter
- `python{version}-venv` - Virtual environment support
- `python3-apt` - APT Python bindings (only with native Python versions)

We deliberately exclude `python-distutils` (deprecated since Python 3.10, removed in 3.12+).
Legacy code requiring distutils may need to install it separately.

See the [main README](../README.md#available-images) for current available versions.

### Pre-installed development tools

All Python images come with these development tools pre-installed via [uv](https://github.com/astral-sh/uv):

- [**prek**](https://github.com/kpumuk/prek) - Pre-commit hook runner
- [**ruff**](https://github.com/astral-sh/ruff) - Fast Python linter and formatter
- [**mypy**](https://github.com/python/mypy) - Static type checker
- [**pytest**](https://github.com/pytest-dev/pytest) - Testing framework
- [**black**](https://github.com/psf/black) - Code formatter
- [**isort**](https://github.com/PyCQA/isort) - Import sorter

## Environment configuration

The following environment variables are pre-configured:

| Variable | Value | Purpose |
|----------|-------|---------|
| `UV_PYTHON` | `python{version}` | Tells uv which Python to use |
| `UV_LINK_MODE` | `copy` | Reduces verbosity in CI logs |
| `PATH` | `/root/.local/bin:$PATH` | Includes uv and installed tools |

The PATH modification ensures `uv` itself is available, tools installed via `uv tool install` are
accessible, and there are no warnings about PATH during tool installation.

## Working with Python

### Managing tools

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

### Virtual environments

Python virtual environment support is built-in:

```bash
# Create a virtual environment
python -m venv .venv

# Or use uv for faster venv creation
uv venv

# Activate it
source .venv/bin/activate
```

## Design decisions

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

### Module not found

If you encounter import errors for standard library modules:

```bash
# Ensure you're using the right Python
which python
python --version

# For virtual environments, check activation
echo $VIRTUAL_ENV
```

### Tool not in PATH

All tools should be in PATH, but if not:

```bash
# Check tool installation
uv tool list

# Manually add to PATH if needed
export PATH="/root/.local/bin:$PATH"
```

### Need a different Python version?

If you need a Python version not included in our images, use the
[actions/setup-python](https://github.com/actions/setup-python) action in your workflow. It
supports all Python versions and includes built-in caching options.
