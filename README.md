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

Looking for a technique rather than an entry? [INDEX.md](INDEX.md) maps
each problem to the feature that solves it and the file that shows it, with
the pitfalls the examples record and the testing patterns worth reusing.

## Local lab

What the examples need, and how to set it up on your own machine. This is
the setup the entries were tested with, on Ubuntu 24.04; GitHub's
`ubuntu-24.04` runner, where CI runs, provides the same.

| What | Version tested | Needed by | How |
|---|---|---|---|
| Python | 3.12 | 01, 09, 10, 12 | your distribution's `python3.12` |
| Python | 3.13 | 02, 05 | your distribution's `python3.13`, or `uv python install 3.13` |
| uv | 0.12.20 | 01, 02, 03, 05, 09, 12 | in a virtualenv, `.lab/` (below) |
| pip-tools | 7.6.1 | 01, 02 | `uv tool install` (below) |
| Poetry | 2.5.1 | 01, 02 | `uv tool install` (below) |
| ansible-core | 2.21.4 | 07, 09, 11 | `uv tool install` (below) |
| ansible-builder | 3.1.1 | 03 | `uv tool install` (below) |
| ansible-navigator | 26.9.0 | 03, 07, 11 | `uv tool install` (below) |
| ansible-dev-environment (ade) | 26.9.0 | 12 | `uv tool install` (below) |
| community.docker | 5.3.0 | 09 (its test only) | `ansible-galaxy collection install` (below) |
| Docker Engine | 29.6 | 03, 07, 08, 09, 11 | Docker Engine or Docker Desktop, with the daemon running and your user allowed to use it |
| Node.js and npm | 22 and 10 | 08 | your distribution's packages, or nodejs.org |
| VS Code and the `redhat.ansible` extension | 26.8.2 | 06, 08, optional | code.visualstudio.com; the examples don't need it to run |

```sh
python3.12 -m venv .lab
.lab/bin/pip install uv==0.12.20
export PATH="$PWD/.lab/bin:$HOME/.local/bin:$PATH"
uv tool install pip-tools==7.6.1
uv tool install poetry==2.5.1
uv tool install ansible-core==2.21.4
uv tool install ansible-builder==3.1.1
uv tool install ansible-navigator==26.9.0
uv tool install ansible-dev-environment==26.9.0
ansible-galaxy collection install community.docker:==5.3.0
./lab/check.sh
```

- **`uv tool install`** puts each tool in an environment of its own, with its
  commands in `~/.local/bin`, so their dependencies don't clash. It's how CI
  keeps them apart too: one throwaway virtualenv per workflow.
- **Some tools come from an example's own lock,** and aren't in the table:
  ADT from part 5's `requirements.txt`, ansible-lint from part 10's, and pip
  26.2.1 for `pip lock`, which part 1 installs in its own virtualenv. Each
  example's README has the commands.
- **`lab/check.sh`** checks each line of the table and prints the command for
  whatever is missing. It changes nothing.
- **Podman instead of Docker:** part 8's Podman configuration and part 9's
  dev server use Podman; the other examples and CI use Docker.
  ansible-navigator uses whichever it finds.

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
- [`index.yml`](.github/workflows/index.yml) fails when an example directory has no row in [INDEX.md](INDEX.md).
