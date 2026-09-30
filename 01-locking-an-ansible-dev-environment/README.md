# Part 1: Locking an Ansible development environment

Example for [Locking an Ansible development environment: pip, venv, pip-tools, uv or an execution environment](https://til.housni.eu/ansible/locking-an-ansible-dev-environment-pip-to-ee.html).

The same two constraints, locked with each tool from the entry's table that
writes a lock file:

```text
ansible-core~=2.21.0
ansible-runner>=2.3.0,<3.0.0
```

| Directory | Tool | You edit | The tool writes | Python versions the lock covers |
|---|---|---|---|---|
| [`pip-tools/`](pip-tools/) | pip-tools 7.6.1 | `requirements.in` | `requirements.txt`, with hashes | 3.12 only, the one it ran under |
| [`uv/`](uv/) | uv 0.12.20 | `pyproject.toml` | `uv.lock` | 3.12 to 3.14 (`requires-python`) |
| [`poetry/`](poetry/) | Poetry 2.5.1 | `pyproject.toml` | `poetry.lock` | 3.12 to 3.14 (`python`) |
| [`pip-lock/`](pip-lock/) | pip 26.2.1, `pip lock` (experimental) | `requirements.in` | `pylock.toml` | 3.12 only, the one it ran under |

All four resolved to ansible-core 2.21.4 and ansible-runner 2.4.3, with the
same 14 packages in total.

The rest of the table has no file here:
- **pip** on its own only locks if you pin every line by hand; `pip lock` is its locking command.
- **venv** isolates, it doesn't lock. Every install below goes into one.
- **An execution environment** is built *from* one of these locks, in [part 3](https://til.housni.eu/ansible/execution-environment-from-a-locked-requirements-file.html).

## How the locks were made

```sh
# pip-tools, run with Python 3.12
cd pip-tools && pip-compile --generate-hashes --strip-extras requirements.in

# uv
cd uv && uv lock

# Poetry
cd poetry && poetry lock

# pip, run with Python 3.12
cd pip-lock && pip lock -r requirements.in -o pylock.toml
```

## Install one

Each command installs the lock into a new venv, without resolving anything again:

```sh
# pip-tools
cd pip-tools
python3.12 -m venv .venv
.venv/bin/pip install --require-hashes -r requirements.txt

# uv: creates .venv itself, and fails if uv.lock doesn't match pyproject.toml
cd uv && uv sync --locked

# Poetry: fails if poetry.lock doesn't match pyproject.toml
cd poetry && poetry check --lock && poetry sync

# pip lock: pip prints that installing from pylock.toml is experimental
cd pip-lock
python3.12 -m venv .venv
.venv/bin/pip install -r pylock.toml
```

Then `ansible --version` reports `ansible [core 2.21.4]`.

## What CI checks

[`.github/workflows/locks.yml`](../.github/workflows/locks.yml) runs on Python 3.12 with each tool at the version above. For each lock, it:
- checks that the lock still matches the file you edit: it reruns `pip-compile` and fails on any diff, and runs `uv lock --check` and `poetry check --lock`. `pip lock` has no check mode, and rerunning it would pick up new releases;
- installs the lock into a fresh venv and runs `ansible --version`.

pip-compile keeps the versions already in `requirements.txt`, so the rerun
only changes the file when `requirements.in` no longer matches it.
