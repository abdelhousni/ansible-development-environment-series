# Part 12: A collection-aware venv with ansible-dev-environment (ade)

Example for [A collection-aware venv with ansible-dev-environment (ade)](https://til.housni.eu/ansible/collection-venv-with-ansible-dev-environment.html).

| File | What it is |
|---|---|
| [`requirements.yml`](requirements.yml) | One collection, `amazon.aws` 11.4.0, which needs boto3, botocore and aiobotocore |
| [`constraints.in`](constraints.in), [`constraints.txt`](constraints.txt) | A lock for ansible-core and those libraries, compiled with `--exclude-newer 2026-06-01T00:00:00Z` so it holds older versions than the newest ones |
| [`ansible.cfg`](ansible.cfg) | `collections_path = ./collections`, the layout from part 11 |
| [`collection/`](collection/) | `myorg.tools`, a minimal collection under development: one filter plugin, a dependency on `ansible.utils`, a `requirements.txt`, and a `bindep.txt` naming a package that doesn't exist |
| [`demo.sh`](demo.sh), [`expected-demo.txt`](expected-demo.txt) | Runs the entry's steps in a scratch copy and prints what each did |

## Run it

```sh
pip install ansible-dev-environment==26.9.0 uv==0.12.20
./demo.sh
```

The script copies this directory to a temporary one, so nothing here changes,
and makes it a git repository to show ade's edits as diffs. Its output is
[`expected-demo.txt`](expected-demo.txt):

**`ade install -r requirements.yml`, with `UV_CONSTRAINT=constraints.txt`:**
- The venv gets exactly the lock's versions: ansible-core 2.21.0, boto3 and botocore 1.43.0, aiobotocore 3.7.0. Without the variable, ade installs the newest that fit.
- amazon.aws 11.4.0 lands in the venv.
- `ansible.cfg` changes from `collections_path = ./collections` to `collections_path = .`: ade's default isolation mode rewrites it. In a real project, commit `ansible.cfg` before running ade, and check the diff.

**`ade install -e .` in `collection/`:**
- ade exits with code 2 and lists `ade-example-missing-package` as a missing system package, from `bindep.txt`. Everything else is installed.
- `galaxy.yml` gains `.venv`, `collections` and `.tox` under `build_ignore`.
- The filter prints `Hello, ade`, and after an edit to the plugin, `Hi, ade`, with no reinstall: the install is a set of symlinks to this directory.

## What CI checks

[`.github/workflows/ade.yml`](../.github/workflows/ade.yml) installs ansible-dev-environment 26.9.0 and uv 0.12.20 on Python 3.12, on every push and pull request. It then:
- runs `demo.sh` and compares its output with `expected-demo.txt`;
- reruns `uv pip compile` on `constraints.in`, and fails if `constraints.txt` changes.
