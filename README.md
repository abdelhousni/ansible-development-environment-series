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
| [`06-vscode-ansible-settings-per-repository/`](06-vscode-ansible-settings-per-repository/) | [Part 6: Committing the VS Code Ansible settings with the repository](https://til.housni.eu/ansible/vscode-ansible-settings-per-repository.html) |
| [`07-develop-against-the-production-execution-environment/`](07-develop-against-the-production-execution-environment/) | [Part 7: Running playbooks locally in the production execution environment](https://til.housni.eu/ansible/develop-against-the-production-execution-environment.html) |
| [`08-ansible-dev-container-with-adt/`](08-ansible-dev-container-with-adt/) | [Part 8: An Ansible Dev Container](https://til.housni.eu/ansible/ansible-dev-container-with-adt.html) |
| [`09-shared-dev-server-for-vscode-remote-ssh/`](09-shared-dev-server-for-vscode-remote-ssh/) | [Part 9: A shared Ansible dev server for VS Code Remote-SSH](https://til.housni.eu/ansible/shared-dev-server-for-vscode-remote-ssh.html) |
| [`10-ansible-lint-fix-in-the-editor-and-in-ci/`](10-ansible-lint-fix-in-the-editor-and-in-ci/) | [Part 10: `--fix` in the editor, the same ansible-lint in CI](https://til.housni.eu/ansible/ansible-lint-fix-in-the-editor-and-in-ci.html) |
| [`11-scaffolding-with-ansible-creator/`](11-scaffolding-with-ansible-creator/) | [Part 11: Scaffolding with ansible-creator](https://til.housni.eu/ansible/scaffolding-with-ansible-creator.html) |
| [`12-collection-venv-with-ansible-dev-environment/`](12-collection-venv-with-ansible-dev-environment/) | [Part 12: A collection-aware venv with ade](https://til.housni.eu/ansible/collection-venv-with-ansible-dev-environment.html) |

GitHub only runs workflows from the repository root, so the examples keep
none of their own. The root workflows cover them:
- [`locks.yml`](.github/workflows/locks.yml) checks and installs each lock file of part 1;
- [`pinning.yml`](.github/workflows/pinning.yml) checks and installs part 2's locks, and its constraint and collection examples;
- [`ee.yml`](.github/workflows/ee.yml) builds the part 3 execution environment and checks it against its lock;
- [`adt.yml`](.github/workflows/adt.yml) checks part 5's per-Python table and installs its ADT lock;
- [`vscode-settings.yml`](.github/workflows/vscode-settings.yml) checks part 6's VS Code settings against the Ansible extension's manifest;
- [`navigator.yml`](.github/workflows/navigator.yml) runs part 7's playbooks in its execution environment;
- [`devcontainer.yml`](.github/workflows/devcontainer.yml) starts part 8's Dev Container and runs a playbook in its EE;
- [`devserver.yml`](.github/workflows/devserver.yml) runs part 9's playbook against a Rocky Linux 9 container and checks the result as a developer;
- [`lint-fix.yml`](.github/workflows/lint-fix.yml) reruns part 10's `--fix` table with the locked ansible-lint;
- [`ade.yml`](.github/workflows/ade.yml) runs part 12's ade steps and checks each result;
- [`ansible-lint.yml`](.github/workflows/ansible-lint.yml) lints the Ansible examples with the pinned workflow from
  [part 10](https://til.housni.eu/ansible/ansible-lint-fix-in-the-editor-and-in-ci.html). Each example's own
  `.ansible-lint` sets its profile.
