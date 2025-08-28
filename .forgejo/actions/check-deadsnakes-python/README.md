# Check Deadsnakes Python Versions Action

A Forgejo/GitHub Actions composite action that queries the deadsnakes PPA to find Python versions
available across specified Ubuntu releases.

## Usage

```yaml
- name: Check available Python versions
  id: python-check
  uses: ./.forgejo/actions/check-deadsnakes-python
  with:
    ubuntu-versions: "22.04 24.04 25.04"

- name: Display results
  run: |
    echo "Common Python versions: ${{ steps.python-check.outputs.python-versions }}"
```

## Inputs

| Input | Description | Default | Required | Example |
|-------|-------------|---------|----------|---------|
| `ubuntu-versions` | Space-separated list of Ubuntu versions | - | Yes | `22.04 24.04 25.04` |
| `limit` | Maximum number of Python versions to return (newest are selected) | `3` | No | `2` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `python-versions` | Space-separated list of Python versions available across ALL specified Ubuntu releases | `3.9 3.11 3.13` (with limit=3) |

## How it works

1. Queries the Launchpad API for the deadsnakes PPA description
2. Parses the "Supported Ubuntu and Python Versions" section
3. Finds the intersection of Python versions across all specified Ubuntu releases
4. Applies the limit (if set) to return only the newest versions
5. Returns only versions available in ALL specified releases

## Example workflow usage

```yaml
name: Build with dynamic Python versions
on: [push]

jobs:
  check-python:
    runs-on: ubuntu-latest
    outputs:
      python-versions: ${{ steps.check.outputs.python-versions }}
    steps:
      - uses: actions/checkout@v4
      - id: check
        uses: ./.forgejo/actions/check-deadsnakes-python
        with:
          ubuntu-versions: "22.04 24.04"

  build:
    needs: check-python
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # Convert space-separated string to array
        python: ${{ fromJSON(format('[{0}]', replace(needs.check-python.outputs.python-versions, ' ', ','))) }}
    steps:
      - name: Build with Python ${{ matrix.python }}
        run: echo "Building with Python ${{ matrix.python }}"
```

## Notes

- Ubuntu versions not supported by deadsnakes (e.g., 25.04) will be noted in the exclusions output
- The action only returns Python versions available via deadsnakes, not native Ubuntu packages
- Python versions are returned in sorted order (e.g., 3.7 before 3.11)
