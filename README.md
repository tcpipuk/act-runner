# ACT Runner Images

Production-ready runner images for [Forgejo Actions](https://forgejo.org/docs/latest/user/actions/)
and [ACT](https://github.com/nektos/act) with comprehensive language support and nightly updates.

## Quick start

Use my convenience tags that track stable versions:

| Tag | Description | Points To |
|-----|-------------|-----------|
| **[`latest`](https://git.tomfos.tr/tom/-/packages/container/act-runner/latest)** | Current stable - Ubuntu 24.04 LTS, Node.js 20/22, Python 3.13 | [`ubuntu24.04-node20-22-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.13) |
| **[`lts`](https://git.tomfos.tr/tom/-/packages/container/act-runner/lts)** | Previous LTS - Ubuntu 22.04 LTS, Node.js 20/22, Python 3.13 | [`ubuntu22.04-node20-22-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.13) |
| **[`edge`](https://git.tomfos.tr/tom/-/packages/container/act-runner/edge)** | Bleeding edge - Ubuntu 25.04, Node.js 22/24, Python 3.13 | [`ubuntu25.04-node22-24-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.13) |

### Usage examples

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

## Available images

**[View all available tags and versions →](https://git.tomfos.tr/tom/-/packages/container/act-runner/versions)**

| Ubuntu | Node.js | Python Versions Available |
|--------|---------|---------------------------|
| 25.04 | 22, 24 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24), [3.9](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.9), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-24-py3.13) |
| 25.04 | 20, 22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22), [3.9](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22-py3.9), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node20-22-py3.13) |
| 25.04 | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-base) |
| 24.04 LTS | 22, 24 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24), [3.9](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.9), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.13), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-24-py3.11) |
| 24.04 LTS | 20, 22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22), [3.9](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.9), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.13), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node20-22-py3.11) |
| 24.04 LTS | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-base) |
| 22.04 LTS | 22, 24 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24), [3.9](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.9), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.13), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-24-py3.11) |
| 22.04 LTS | 20, 22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22), [3.9](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.9), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.13), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-22-py3.11) |
| 22.04 LTS | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-base) |

## Why these images?

- **Wide compatibility** - Works with Forgejo Actions, Gitea Actions, and ACT
- **Multi-architecture support** - Built for amd64, arm64, ppc64le, and s390x
- **Always current** - Automatically tracks all supported Node.js and Python versions
- **Nightly updates** with intelligent layering - only download what's changed
- **Pre-configured tools** - Docker, build-essential, gh CLI, and development libraries ready to go
- **Smart caching** - Layered architecture means updates are incremental, not full re-downloads

## What's included

**All images include:**

- Build essentials (gcc, g++, make, cmake, pkg-config)
- Full Docker stack including daemon, CLI and Compose (via Ubuntu's `docker.io` package for
  guaranteed multi-architecture support and Docker-in-Docker capabilities)
- [GitHub CLI](https://cli.github.com/manual/) (`gh`)
- Git and Git LFS
- Common utilities (curl, wget, jq, tar, zip)
- Pre-configured package repositories (Kubernetes, HashiCorp, PostgreSQL, Microsoft)

**Node.js images add:**

- Multiple [Node.js](https://nodejs.org/) versions with npm/npx
- Compatible with [actions/setup-node](https://github.com/actions/setup-node)

**Python images add:**

- Python 3.11 and/or 3.13 (see table above)
- [uv](https://docs.astral.sh/uv/) package manager
- Pre-installed development tools (ruff, mypy, pytest, black, isort, prek)
- See [docs/python.md](docs/python.md) for full details

## Building your own

Need to customise these images? See [docs/self-build.md](docs/self-build.md) for detailed build instructions.

## Credits

Inspired by [catthehacker/docker_images](https://github.com/catthehacker/docker_images). This
project provides automated builds with wider version coverage and optimised layer caching.

## License

MIT - See [LICENSE](LICENSE) file for details.
