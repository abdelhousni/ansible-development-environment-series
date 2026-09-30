# Part 5: Ansible Development Tools (ADT)

Example for [Ansible Development Tools (ADT): one install, and the Python version decides what you get](https://til.housni.eu/ansible/ansible-development-tools-adt.html).

| File | What it is |
|---|---|
| [`resolve-by-python.sh`](resolve-by-python.sh) | Resolves `ansible-dev-tools` for Python 3.9 to 3.14 and prints what each gets |
| [`expected-by-python.txt`](expected-by-python.txt) | Its output: the entry's table |
| [`requirements.in`](requirements.in) | `ansible-dev-tools==26.9.0` |
| [`requirements.txt`](requirements.txt) | The lock: all 69 packages pinned, with hashes, for Python 3.13 on Linux |
| [`site.yml`](site.yml) | A playbook that prints the ansible-core running it |

## The Python version decides what you get

```sh
./resolve-by-python.sh
```

```text
python adt ansible-core packages
3.9 none none 0
3.10 25.10.0 2.16.19 71
3.11 26.9.0 2.19.13 69
3.12 26.9.0 2.21.4 69
3.13 26.9.0 2.21.4 69
3.14 26.9.0 2.21.4 69
```

The script runs `uv pip compile` once per Python version, with
`--exclude-newer 2026-09-30T00:00:00Z`. That option makes uv ignore every
package uploaded after that time. So the result stays the same as on the day
the entry was tested, even after new releases. Without it, the ADT versions,
tools and counts move as PyPI does.

## ADT sets floors, so lock it

`ansible-dev-tools==26.9.0` pins ADT itself. Its dependencies are only lower
bounds, so the lock pins everything else:

```sh
uv pip compile requirements.in --python-version 3.13 --python-platform linux --generate-hashes -o requirements.txt
```

To install it:

```sh
uv venv --python 3.13 .venv
uv pip sync --python .venv/bin/python requirements.txt
.venv/bin/adt --version
```

`adt --version` then lists the versions from the entry's first table.

## `--ee false` needs the venv on `PATH`

ansible-navigator runs playbooks in an execution environment by default.
With `--ee false`, it runs them with the `ansible-playbook` it finds on
`PATH` instead:

```sh
.venv/bin/ansible-navigator run site.yml --ee false --mode stdout
```

- **With the venv's `bin/` not on `PATH`**, it stops: `ansible: not found`.
- **With it on `PATH`**, for example after `source .venv/bin/activate`, it prints `"msg": "ansible-core 2.21.4"`.

## What CI checks

[`.github/workflows/adt.yml`](../.github/workflows/adt.yml) runs on every push and pull request. It:
- reruns `resolve-by-python.sh` and compares its output with `expected-by-python.txt`;
- reruns `uv pip compile` and fails if `requirements.txt` changes;
- installs the lock with Python 3.13 and checks the `adt --version` lines for ansible-core and ansible-lint;
- runs `site.yml` with `--ee false`, once with a `PATH` that has no `ansible` and expects `ansible: not found`, then with only the venv's `bin/` and expects ansible-core 2.21.4.
