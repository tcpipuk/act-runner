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

| Ubuntu Version | Alias Tag | Node.js | Python Versions Available |
|----------------|-----------|---------|---------------------------|
| 25.04 (Development) | **[`ubuntu-rolling`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu-rolling)** | 24 | [***3.13***](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu25.04-node24-py3.13) |
| 24.04 LTS (Current) | **[`ubuntu-latest`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu-latest)** | 22 | [***3.12***](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-py3.12), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu24.04-node22-py3.13) |
| 22.04 LTS (Previous) | **[`ubuntu-previous`](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu-previous)** | 20 | [***3.10***](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-py3.10), [3.13](https://git.tomfos.tr/tom/-/packages/container/act-runner/ubuntu22.04-node20-py3.13) |

**Note**: ***Italicised*** versions are the native Python for each Ubuntu release. Non-native
versions use the latest stable Python (3.13) from deadsnakes PPA.

## Fedora images

**[View all available tags and versions →](https://git.tomfos.tr/tom/-/packages/container/act-runner/versions)**

| Fedora Version | Alias Tag | Node.js | Python Versions Available |
|----------------|-----------|---------|---------------------------|
| Rawhide (Development) | **[`fedora-rawhide`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora-rawhide)** | 24 | [**3.14**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedorarawhide-node24-py3.14) |
| 42 (Current) | **[`fedora-latest`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora-latest)** | 22 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora42-node22-py3.13) |
| 41 (Previous) | **[`fedora-previous`](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora-previous)** | 20 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/fedora41-node20-py3.13) |

## Debian images

**[View all available tags and versions →](https://git.tomfos.tr/tom/-/packages/container/act-runner/versions)**

| Debian Version | Alias Tag | Node.js | Python Versions Available |
|----------------|-----------|---------|---------------------------|
| sid (Forky - Sid/Unstable) | **[`debian-sid`](https://git.tomfos.tr/tom/-/packages/container/act-runner/debian-sid)** | 24 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/debiansid-node24-py3.13) |
| 13 (Trixie - Stable) | **[`debian-latest`](https://git.tomfos.tr/tom/-/packages/container/act-runner/debian-latest)** | 22 | [**3.13**](https://git.tomfos.tr/tom/-/packages/container/act-runner/debian13-node22-py3.13) |
| 12 (Bookworm - Oldstable) | **[`debian-oldstable`](https://git.tomfos.tr/tom/-/packages/container/act-runner/debian-oldstable)** | 20 | [**3.11**](https://git.tomfos.tr/tom/-/packages/container/act-runner/debian12-node20-py3.11) |

**Note**: Debian images use only the native Python version for each release,
providing better system integration than external PPAs.

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
- Full Docker stack including daemon, CLI and Compose (via `docker.io` package on
  Ubuntu/Debian, `moby-engine` on Fedora, all with multi-architecture support and
  Docker-in-Docker capabilities)
- [GitHub CLI](https://cli.github.com/manual/) (`gh`)
- Git and Git LFS
- Common utilities (curl, wget, jq, tar, zip)
- Pre-configured package repositories (LLVM, Kubernetes, HashiCorp*, Microsoft)
- Deadsnakes PPA repository (non-rolling Ubuntu releases only)

> [!NOTE]
> \* HashiCorp repository is not available for Debian sid/unstable

**Runtime languages:**

- [Node.js](https://nodejs.org/) with npm/npx (single version per image: oldest supported
  LTS for 'previous/oldstable' releases, newest LTS for 'latest/stable' releases, newest
  stable for 'rolling/rawhide/sid' releases)
- Python (native OS version, plus optionally latest stable Python from deadsnakes PPA for
  non-rolling Ubuntu releases)
- [uv](https://docs.astral.sh/uv/) package manager
- Rust toolchain manager (rustup) with minimal profile
- Pre-installed Python development tools (ruff, mypy, pytest, black, isort, prek)
- Compatible with [actions/setup-node](https://github.com/actions/setup-node)
- See [docs/python.md](docs/python.md) for full details

## Building your own

Need to customise these images? See [docs/self-build.md](docs/self-build.md) for detailed build instructions.

## Credits

Inspired by [catthehacker/docker_images](https://github.com/catthehacker/docker_images). This
project provides automated builds with wider version coverage and optimised layer caching.

## License

MIT - See [LICENSE](LICENSE) file for details.
