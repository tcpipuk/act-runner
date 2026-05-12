# Check Deadsnakes Python Versions Action

A Forgejo/GitHub Actions composite action that queries the deadsnakes PPA to find Python versions
available across specified Ubuntu releases.

## Usage

```yaml
- name: Check available Python versions
  id: python-check
  uses: ./.forgejo/actions/check-deadsnakes-versions
  with:
    ubuntu-codenames: "jammy noble resolute"

- name: Display results
  run: |
    echo "Common Python versions: ${{ steps.python-check.outputs.python-versions }}"
```

## Inputs

| Input              | Description                                                       | Default | Required | Example                 |
| ------------------ | ----------------------------------------------------------------- | ------- | -------- | ----------------------- |
| `ubuntu-codenames` | Space-separated list of Ubuntu codenames                          | -       | Yes      | `jammy noble resolute`  |
| `limit`            | Maximum number of Python versions to return (newest are selected) | `3`     | No       | `2`                     |

## Outputs

| Output            | Description                                                                            | Example                        |
| ----------------- | -------------------------------------------------------------------------------------- | ------------------------------ |
| `python-versions` | Space-separated list of Python versions available across ALL specified Ubuntu releases | `3.9 3.11 3.13` (with limit=3) |

## How it works

1. For each Ubuntu codename, queries Launchpad's `getPublishedSources` for source packages whose
   name starts with `python3.` in the deadsnakes PPA
2. Keeps only entries matching `pythonX.Y` exactly (filtering out variants like `pythonX.Y-dbg`)
3. Computes the intersection of Python versions across all specified releases
4. Applies the limit (if set) to return only the newest versions

This reads the published package list directly rather than scraping the PPA description, so it
survives future description-format changes by deadsnakes.

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
        uses: ./.forgejo/actions/check-deadsnakes-versions
        with:
          ubuntu-codenames: "jammy noble"

  build:
    needs: check-python
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # Convert space-separated string to array
        python:
          ${{ fromJSON(format('[{0}]', replace(needs.check-python.outputs.python-versions, ' ',
          ','))) }}
    steps:
      - name: Build with Python ${{ matrix.python }}
        run: echo "Building with Python ${{ matrix.python }}"
```

## Notes

- Codenames that don't exist in Launchpad will produce a warning and contribute no versions to the
  intersection
- The action only returns Python versions available via deadsnakes, not native Ubuntu packages
- Python versions are returned in sorted order (e.g., 3.7 before 3.11)
