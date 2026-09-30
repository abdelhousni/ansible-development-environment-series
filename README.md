# Ansible development environment series: examples

Runnable examples for the **Ansible development environment** series on
[til.housni.eu](https://til.housni.eu/). Each directory belongs to one entry
of the series and is self-contained.

| Directory | Entry |
|---|---|
| [`01-locking-an-ansible-dev-environment/`](01-locking-an-ansible-dev-environment/) | [Part 1: Locking an Ansible development environment](https://til.housni.eu/ansible/locking-an-ansible-dev-environment-pip-to-ee.html) |
| [`11-scaffolding-with-ansible-creator/`](11-scaffolding-with-ansible-creator/) | [Part 11: Scaffolding with ansible-creator](https://til.housni.eu/ansible/scaffolding-with-ansible-creator.html) |

GitHub only runs workflows from the repository root, so the examples keep
none of their own. The root workflows cover them:
- [`locks.yml`](.github/workflows/locks.yml) checks and installs each lock file of part 1;
- [`ansible-lint.yml`](.github/workflows/ansible-lint.yml) lints the Ansible examples with the pinned workflow from
  [part 10](https://til.housni.eu/ansible/ansible-lint-fix-in-the-editor-and-in-ci.html). Each example's own
  `.ansible-lint` sets its profile.
