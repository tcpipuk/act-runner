# ACT Runner Images

Production-ready runner images for [Forgejo Actions](https://forgejo.org/docs/latest/user/actions/)
and [ACT](https://github.com/nektos/act) with comprehensive language support and nightly updates.

> [!NOTE]
> Images are built nightly on [my Forgejo instance](https://git.tomfos.tr/tom/act-runner) and
> automatically mirrored to [GitHub Container Registry](https://github.com/tcpipuk/act-runner/pkgs/container/act-runner)
> for optimal CDN performance. Both `ghcr.io/tcpipuk/act-runner` and `git.tomfos.tr/tom/act-runner`
> *should* be identical multi-architecture images supporting amd64, arm64, ppc64le, and s390x.

## Usage examples

**GitHub Actions:**

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/tcpipuk/act-runner:ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python --version
      - run: node --version
```

**ACT:**

```bash
act -P ubuntu-latest=ghcr.io/tcpipuk/act-runner:ubuntu-latest
```

## Ubuntu images

**[View all available tags and versions →](https://git.tomfos.tr/tom/-/packages/container/act-runner/versions)**

| Ubuntu | Node.js | Python Versions Available |
|--------|---------|---------------------------|
| **[`ubuntu-rolling`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu-rolling)** - Bleeding edge | 24/22 | [`ubuntu25.04-node24-22-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node24-22-py3.13) |
| **[`ubuntu-latest`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu-latest)** - Current stable | 24/22 | [`ubuntu24.04-node24-22-py3.12`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node24-22-py3.12) |
| **[`ubuntu-lts`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu-lts)** - Previous LTS | 22/20 | [`ubuntu22.04-node22-20-py3.10`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-20-py3.10) |
|  |  |  |
| 25.04 | 24/22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node24-22), [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node24-22-py3.13) |
| 25.04 | 22/20 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-20), [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node22-20-py3.13) |
| 25.04 | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-base) |
| 24.04 LTS | 24/22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node24-22), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node24-22-py3.10), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node24-22-py3.11), [**3.12**](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node24-22-py3.12), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node24-22-py3.13) |
| 24.04 LTS | 22/20 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-20), [3.10](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-20-py3.10), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-20-py3.11), [**3.12**](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-20-py3.12), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-20-py3.13) |
| 24.04 LTS | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-base) |
| 22.04 LTS | 24/22 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node24-22), [**3.10**](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node24-22-py3.10), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node24-22-py3.11), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node24-22-py3.12), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node24-22-py3.13) |
| 22.04 LTS | 22/20 | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-20), [**3.10**](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-20-py3.10), [3.11](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-20-py3.11), [3.12](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-20-py3.12), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node22-20-py3.13) |
| 22.04 LTS | None | [None](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-base) |

## Fedora images

**[View all available tags and versions →](https://git.tomfos.tr/tom/-/packages/container/act-runner/versions)**

| Fedora | Node.js | Python Versions Available |
|--------|---------|---------------------------|
| **[`fedora-rawhide`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora-rawhide)** - Development | 24/22 | [`fedorarawhide-node24-22-py3.14`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedorarawhide-node24-22-py3.14) |
| **[`fedora-latest`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora-latest)** - Current stable | 24/22 | [`fedora42-node24-22-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora42-node24-22-py3.13) |
| **[`fedora-lts`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora-lts)** - LTS release | 22/20 | [`fedora41-node22-20-py3.13`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora41-node22-20-py3.13) |
|  |  |  |
| Rawhide | 24/22 | [**3.14**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedorarawhide-node24-22-py3.14) |
| 42 | 24/22 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora42-node24-22-py3.13) |
| 42 | 22/20 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora42-node22-20-py3.13) |
| 41 | 24/22 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora41-node24-22-py3.13) |
| 41 | 22/20 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora41-node22-20-py3.13) |

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
- Pre-configured package repositories (LLVM, Kubernetes, HashiCorp, Microsoft)

**Node.js images add:**

- Multiple [Node.js](https://nodejs.org/) versions with npm/npx
- Compatible with [actions/setup-node](https://github.com/actions/setup-node)

**Python images add:**

- Python (native Ubuntu version or from deadsnakes PPA)
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
