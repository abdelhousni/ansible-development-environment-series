# Part 2: Pinning ansible-core with pip-tools, uv and Poetry

Example for [Pinning ansible-core with pip-tools, uv and Poetry](https://til.housni.eu/ansible/pinning-ansible-core-pip-tools-uv-poetry.html).

| Directory | What it holds |
|---|---|
| [`pip-tools/requirements/`](pip-tools/requirements/) | `base.in` and its lock `base.txt`; `dev.in`, constrained by `base.txt`, and its lock `dev.txt` |
| [`uv/`](uv/) | `pyproject.toml` with a `dev` dependency group, and `uv.lock` |
| [`poetry/`](poetry/) | `pyproject.toml` with a `dev` group, and `poetry.lock` |
| [`collections/`](collections/) | `requirements.yml`: `community.general` with a range below the next major version |
| [`constraints/`](constraints/) | What each constraint syntax resolves to, and Poetry's `^` trap |

## Two commits: an exact pin, then a patch upgrade

- **The first commit** pins `ansible-core==2.21.0` in all three tools and locks it.
- **The second** relaxes the pin to `~=2.21.0`, or `~2.21.0` in Poetry, and moves to the latest patch release:

```sh
cd pip-tools
pip-compile --upgrade-package ansible-core requirements/base.in
pip-compile --upgrade-package ansible-core requirements/dev.in
cd ../uv && uv lock --upgrade-package ansible-core
cd ../poetry && poetry update --lock ansible-core
```

`git show` on the second commit shows what the entry describes. Before the
upgrade commands, re-locking with the relaxed constraint kept 2.21.0. After
them, ansible-core is 2.21.4 in every lock, and no other package changed.
`poetry update ansible-core` without `--lock` also installs the result.

## Constraint syntax

```sh
constraints/resolve-constraints.sh
```

This resolves ansible-core under each constraint with uv, for Python 3.13. It
passes `--exclude-newer 2026-09-30T00:00:00Z`, so uv ignores anything
uploaded to PyPI after the entry was tested. Its output is
[`expected-constraints.txt`](constraints/expected-constraints.txt):

```text
==2.21.4 2.21.4
>=2.21.0,<2.22 2.21.4
~=2.21.0 2.21.4
~2.21.0 parse-error
^2.21.0 parse-error
~=2.21 2.21.4
~=2.15 2.21.4
~=2.15.9 2.15.13
>=2.15.0,<2.16.0 2.15.13
```

`~2.21.0` and `^2.21.0` are Poetry syntax, which uv and pip-tools reject.
`~=2.15` has only two parts, so it allows anything up to 3.0 and jumps to
2.21. [`constraints/poetry-caret/`](constraints/poetry-caret/) shows the same
jump in Poetry: `ansible-core = "^2.15.9"` locked 2.21.4.

## What CI checks

[`.github/workflows/pinning.yml`](../.github/workflows/pinning.yml) runs on every push and pull request, on Python 3.13:
- **pip-tools:** reruns both `pip-compile` commands and fails on any change, then installs `dev.txt` and checks the ansible-core and ansible-lint versions;
- **uv:** `uv lock --check`, then `uv sync --locked` and the same version checks;
- **Poetry:** `poetry check --lock` on both projects, `poetry sync` and the version checks, and 2.21.4 in the caret project's lock;
- **constraints:** reruns `resolve-constraints.sh` and compares it with the expected output;
- **collections:** installs `requirements.yml` and checks that `community.general` stays on 13.x. There is no collection lock, so the exact version can change.
