# ACT Runner Images

Production-ready runner images for [Forgejo Actions](https://forgejo.org/docs/latest/user/actions/)
and [ACT](https://github.com/nektos/act) with comprehensive language support and nightly updates.

## Quick Start

Use my convenience tags that track stable versions:

| Tag | Description | Points To |
|-----|-------------|-----------|
| **[`latest`](https://git.tomfos.tr/tom/-/packages/container/act-runner/latest)** | Current stable - Ubuntu 24.04 LTS, Node.js 20/22, Python 3.13 | [`ubuntu24.04-node20-22-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.13) |
| **[`lts`](https://git.tomfos.tr/tom/-/packages/container/act-runner/lts)** | Previous LTS - Ubuntu 22.04 LTS, Node.js 20/22, Python 3.13 | [`ubuntu22.04-node20-22-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.13) |
| **[`edge`](https://git.tomfos.tr/tom/-/packages/container/act-runner/edge)** | Bleeding edge - Ubuntu 25.04, Node.js 22/24, Python 3.14 | [`ubuntu25.04-node22-24-py3.14`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.14) |

### Usage Examples

**Forgejo/Gitea Actions:**

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: git.tomfos.tr/tom/act-runner:latest
    steps:
      - uses: actions/checkout@v4
      - run: python --version  # Python 3.13
      - run: node --version    # Node.js 20
```

**ACT:**

```bash
act -P ubuntu-latest=git.tomfos.tr/tom/act-runner:latest
```

## Available Images

**[View all available tags and versions →](https://git.tomfos.tr/tom/-/packages/container/act-runner/versions)**

| Ubuntu | Node.js | Python Versions Available |
|--------|---------|---------------------------|
| 25.04 | 22, 24 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.10) |
| 25.04 | 20, 22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22-py3.10) |
| 25.04 | 18, 20 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node18-20), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node18-20-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node18-20-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node18-20-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node18-20-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node18-20-py3.10) |
| 25.04 | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-base) |
| 24.04 LTS | 22, 24 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.10) |
| 24.04 LTS | 20, 22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.10) |
| 24.04 LTS | 18, 20 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node18-20), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node18-20-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node18-20-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node18-20-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node18-20-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node18-20-py3.10) |
| 24.04 LTS | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-base) |
| 22.04 LTS | 22, 24 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.10) |
| 22.04 LTS | 20, 22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.10) |
| 22.04 LTS | 18, 20 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node18-20), [3.14](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node18-20-py3.14), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node18-20-py3.13), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node18-20-py3.12), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node18-20-py3.11), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node18-20-py3.10) |
| 22.04 LTS | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-base) |

## Why These Images?

- **Wide compatibility** - Works with Forgejo Actions, Gitea Actions, and ACT
- **Extensive version matrix** - Ubuntu 22.04/24.04/25.04, Python 3.10-3.14, Node.js 18-24
- **Nightly updates** with intelligent layering - only download what's changed
- **Pre-configured tools** - Docker, build-essential, gh CLI, and development libraries ready to go
- **Smart caching** - Layered architecture means updates are incremental, not full re-downloads

## What's Included

**All images include:**

- Build essentials (gcc, g++, make, cmake, pkg-config)
- Docker CLI and Docker Compose plugin
- [GitHub CLI](https://cli.github.com/manual/) (`gh`)
- Git and Git LFS
- Common utilities (curl, wget, jq, tar, zip)
- Pre-configured package repositories (Docker, Kubernetes, HashCorp, PostgreSQL, Microsoft)

**Node.js images add:**

- Multiple [Node.js](https://nodejs.org/) versions with npm/npx
- Compatible with [actions/setup-node](https://github.com/actions/setup-node)

**Python images add:**

- Python via [deadsnakes PPA](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa)
- [uv](https://docs.astral.sh/uv/) package manager
- Pre-installed: [prek](https://github.com/j178/prek), [ruff](https://docs.astral.sh/ruff/),
  [mypy](https://mypy.readthedocs.io/), [pytest](https://docs.pytest.org/),
  [black](https://black.readthedocs.io/), [isort](https://pycqa.github.io/isort/)

## Building Your Own

Need to customise these images? See [docs/self-build.md](docs/self-build.md) for detailed build instructions.

## Credits

Inspired by [catthehacker/docker_images](https://github.com/catthehacker/docker_images). This
project provides automated builds with wider version coverage and optimised layer caching.

## License

MIT - See [LICENSE](LICENSE) file for details.
