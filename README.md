# Ansible development environment series: examples

Runnable examples for the **Ansible development environment** series on
[til.housni.eu](https://til.housni.eu/). Each directory belongs to one entry
of the series and is self-contained.

| Directory | Entry |
|---|---|
| [`01-locking-an-ansible-dev-environment/`](01-locking-an-ansible-dev-environment/) | [Part 1: Locking an Ansible development environment](https://til.housni.eu/ansible/locking-an-ansible-dev-environment-pip-to-ee.html) |
| [`02-pinning-ansible-core-pip-tools-uv-poetry/`](02-pinning-ansible-core-pip-tools-uv-poetry/) | [Part 2: Pinning ansible-core with pip-tools, uv and Poetry](https://til.housni.eu/ansible/pinning-ansible-core-pip-tools-uv-poetry.html) |
| [`03-execution-environment-from-a-locked-requirements-file/`](03-execution-environment-from-a-locked-requirements-file/) | [Part 3: Building an execution environment from a locked requirements file](https://til.housni.eu/ansible/execution-environment-from-a-locked-requirements-file.html) |
| [`05-ansible-development-tools-adt/`](05-ansible-development-tools-adt/) | [Part 5: Ansible Development Tools (ADT)](https://til.housni.eu/ansible/ansible-development-tools-adt.html) |
| [`11-scaffolding-with-ansible-creator/`](11-scaffolding-with-ansible-creator/) | [Part 11: Scaffolding with ansible-creator](https://til.housni.eu/ansible/scaffolding-with-ansible-creator.html) |

GitHub only runs workflows from the repository root, so the examples keep
none of their own. The root workflows cover them:
- [`locks.yml`](.github/workflows/locks.yml) checks and installs each lock file of part 1;
- [`pinning.yml`](.github/workflows/pinning.yml) checks and installs part 2's locks, and its constraint and collection examples;
- [`ee.yml`](.github/workflows/ee.yml) builds the part 3 execution environment and checks it against its lock;
- [`adt.yml`](.github/workflows/adt.yml) checks part 5's per-Python table and installs its ADT lock;
- [`ansible-lint.yml`](.github/workflows/ansible-lint.yml) lints the Ansible examples with the pinned workflow from
  [part 10](https://til.housni.eu/ansible/ansible-lint-fix-in-the-editor-and-in-ci.html). Each example's own
  `.ansible-lint` sets its profile.
