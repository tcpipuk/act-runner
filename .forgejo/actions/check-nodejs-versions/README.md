# Check Node.js Versions Action

A Forgejo/GitHub Actions composite action that queries the official Node.js release schedule to find
currently supported versions.

## Usage

```yaml
- name: Check Node.js versions
  id: node-check
  uses: ./.forgejo/actions/check-nodejs-versions

- name: Display results
  run: |
    echo "LTS versions: ${{ steps.node-check.outputs.lts-versions }}"
    echo "All supported versions: ${{ steps.node-check.outputs.live-versions }}"
```

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `lts-versions` | Space-separated list of Node.js LTS versions | `18 20 22` |
| `live-versions` | Space-separated list of all supported Node.js versions | `18 20 22 24` |

## How it works

1. Queries the official Node.js release schedule from GitHub
2. Filters for currently supported versions (between start and end dates)
3. Excludes odd-numbered versions (development/unstable releases)
4. Identifies which versions are LTS
5. Returns sorted lists of version numbers

## Example workflow usage

```yaml
name: Build with dynamic Node.js versions
on: [push]

jobs:
  check-node:
    runs-on: ubuntu-latest
    outputs:
      lts-versions: ${{ steps.check.outputs.lts-versions }}
      live-versions: ${{ steps.check.outputs.live-versions }}
    steps:
      - uses: actions/checkout@v4
      - id: check
        uses: ./.forgejo/actions/check-nodejs-versions

  build-lts:
    needs: check-node
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: ${{ fromJSON(format('[{0}]', replace(needs.check-node.outputs.lts-versions, ' ', ','))) }}
    steps:
      - name: Build with Node.js ${{ matrix.node }}
        run: echo "Building with Node.js ${{ matrix.node }}"
```

## Notes

- Only returns even-numbered versions (stable releases)
- LTS versions are only included after their LTS start date
- Version numbers are returned without the 'v' prefix
