# Technique index

The series' examples, by problem rather than by entry: what each problem
calls for, and the file that shows it. Each row points to an example whose
CI runs it, unless it says otherwise. Below the techniques are the pitfalls
the examples record, and the testing patterns worth reusing.

## Locking the Python packages

| Problem | Feature | Where |
|---|---|---|
| Lock ansible-core and its dependencies, hashes included | `pip-compile --generate-hashes` from a `requirements.in` | `01-locking-an-ansible-dev-environment/pip-tools/` |
| One lock for several Python versions | `uv lock` with `requires-python`, or Poetry's `python` range | `01-locking-an-ansible-dev-environment/uv/`, `poetry/` |
| Install a lock without resolving again | `pip install --require-hashes -r`, `uv sync --locked`, `poetry sync` | `01-locking-an-ansible-dev-environment/README.md` |
| Fail CI when a lock no longer matches what you edit | rerun `pip-compile` and diff, `uv lock --check`, `poetry check --lock` | `.github/workflows/locks.yml` |
| Keep dev tools out of the runtime lock, on the same versions | a `dev.in` constrained by `base.txt`; a `dev` group in uv or Poetry | `02-pinning-ansible-core-pip-tools-uv-poetry/pip-tools/requirements/` |
| Move to the latest patch release and nothing else | `--upgrade-package ansible-core`, `uv lock --upgrade-package`, `poetry update --lock` | `02-pinning-ansible-core-pip-tools-uv-poetry/README.md` |
| Get the same resolution months later | `uv pip compile --exclude-newer <date>` | `02-…/constraints/resolve-constraints.sh`, `05-…/resolve-by-python.sh` |
| See which ADT each Python version gets | `uv pip compile --python-version` once per version | `05-ansible-development-tools-adt/resolve-by-python.sh` |
| Lock a tool for a server's platform from another machine | `uv pip compile --python-platform x86_64-manylinux_2_34` | `09-shared-dev-server-for-vscode-remote-ssh/README.md` |
| Lock the libraries a collection needs | a constraints file, passed to ade with `UV_CONSTRAINT` | `12-collection-venv-with-ansible-dev-environment/constraints.in` |

## Collections

| Problem | Feature | Where |
|---|---|---|
| Stay on a collection's major version | a range below the next major in `requirements.yml` | `02-pinning-ansible-core-pip-tools-uv-poetry/collections/` |
| Pin every collection of an EE, dependencies included | `==` for each collection, and for what it depends on | `03-execution-environment-from-a-locked-requirements-file/requirements.yml` |
| Let `ansible-doc` and playbooks find the project's own roles | `collections_path = ./collections` in `ansible.cfg` | `11-scaffolding-with-ansible-creator/ansible.cfg` |
| Install a collection with its Python dependencies into a venv | `ade install -r requirements.yml` | `12-collection-venv-with-ansible-dev-environment/demo.sh` |
| Edit a collection and use it without reinstalling | `ade install -e .`, which symlinks it into the venv | `12-collection-venv-with-ansible-dev-environment/collection/` |

## Execution environments

| Problem | Feature | Where |
|---|---|---|
| Build an EE from a lock | `execution-environment.yml` with the base image by digest and `requirements.txt` | `03-execution-environment-from-a-locked-requirements-file/` |
| Check that an EE holds exactly the lock | `pip list` in the image compared with `requirements.txt` | `.github/workflows/ee.yml` |
| Run playbooks locally in the EE production uses | `ansible-navigator.yml` with the image by digest and `pull: policy: missing` | `07-develop-against-the-production-execution-environment/ansible-navigator.yml` |
| Pass one environment variable into the EE, and only that one | `environment-variables.pass` | `07-develop-against-the-production-execution-environment/ansible-navigator.yml` |
| Run a playbook with the venv's ansible-core instead of an EE | `ansible-navigator run --ee false`, with the venv's `bin/` on `PATH` | `05-ansible-development-tools-adt/README.md` |
| Share one EE image between developers on a server | a read-only additional image store for rootless Podman | `09-shared-dev-server-for-vscode-remote-ssh/devserver.yml` |

## Editor and dev environments

| Problem | Feature | Where |
|---|---|---|
| Give everyone the same Ansible extension settings | `.vscode/settings.json` and `extensions.json` in the repository | `06-vscode-ansible-settings-per-repository/.vscode/` |
| Catch a misspelled or wrong-typed extension setting | check the settings against the extension's `package.json` | `06-vscode-ansible-settings-per-repository/check-settings.py` |
| One container with every Ansible tool, pinned | a Dev Container on the ADT image by digest | `08-ansible-dev-container-with-adt/.devcontainer/` |
| Start a Dev Container without VS Code | `devcontainer up` and `exec` from a locked `@devcontainers/cli` | `08-ansible-dev-container-with-adt/tools/` |
| A shared server for VS Code Remote-SSH, set up by Ansible | one locked ADT venv in `/opt/adt`, per-user settings, lingering | `09-shared-dev-server-for-vscode-remote-ssh/devserver.yml` |
| Start a project with the standard layout | `ansible-creator init playbook`, then `add resource role` | `11-scaffolding-with-ansible-creator/README.md` |

## Linting

| Problem | Feature | Where |
|---|---|---|
| Fix lint findings as you save | `ansible.validation.lint.autoFixOnSave` in the extension settings | `10-ansible-lint-fix-in-the-editor-and-in-ci/.vscode/settings.json` |
| See what `--fix` can and can't fix | `ansible-lint --fix` repeated, linting after each pass | `10-ansible-lint-fix-in-the-editor-and-in-ci/reproduce-fix.sh` |
| The same ansible-lint in the editor and in CI | a locked `ansible-lint==` and the action pinned by SHA | `10-…/requirements.txt`, `.github/workflows/ansible-lint.yml` |
| Set a profile per project | `.ansible-lint` with `profile: production` next to the project | `10-…/.ansible-lint`, `11-…/.ansible-lint` |

## Pitfalls recorded

- `pip lock` has no check mode: rerunning it picks up new releases
  (`01-locking-an-ansible-dev-environment/README.md`).
- Relaxing a pin and locking again keeps the old version: you also need an
  upgrade command (`02-pinning-ansible-core-pip-tools-uv-poetry/README.md`).
- `~=2.15` allows anything below 3.0 and jumped to 2.21; Poetry's `^2.15.9`
  locked 2.21.4 too (`02-…/constraints/`).
- `~2.21.0` and `^2.21.0` are Poetry syntax; uv and pip-tools reject them
  (`02-…/constraints/expected-constraints.txt`).
- A collection range has no lock: the exact version can change between installs
  (`02-pinning-ansible-core-pip-tools-uv-poetry/collections/`).
- `fedora:latest` has no Python, and ansible-builder fails with
  `/usr/bin/python3 is not an executable` (first commit of `03-…`).
- quay.io moved the `fedora:44` tag daily and stopped serving the old digest;
  registry.fedoraproject.org still served it (`03-…/README.md`).
- ADT pins itself, but its dependencies are only floors; Python 3.9 gets no
  ADT at all (`05-ansible-development-tools-adt/expected-by-python.txt`).
- `ansible-navigator --ee false` stops with `ansible: not found` when the
  venv's `bin/` isn't on `PATH` (`05-ansible-development-tools-adt/README.md`).
- VS Code silently ignores a misspelled setting key
  (`06-vscode-ansible-settings-per-repository/check-settings.py`).
- A collection installed next to the playbook brings its code, not its Python
  dependencies: the run fails one step later, on jmespath (`07-…/README.md`).
- The EE decides which collections exist: a filter from a missing collection
  fails (`07-…/needs-general.yml`).
- Without an EE in `ansible-navigator.yml`, navigator falls back to the 2 GB
  ADT image `latest` and pulls it on every run (`08-…/README.md`).
- In a CI container, rootless Podman needs file capabilities on
  `newuidmap`/`newgidmap`, and Ubuntu 24.04 runners block user namespaces
  (`09-…/README.md`).
- `write_list` in `.ansible-lint` fixes on every run, and `--fix=none` can't
  turn it off; a formatting-only run exits 8 (`10-…/README.md`).
- ansible-creator's `ansible.cfg` sets `host_vars_inventory` and
  `group_vars_inventory`, which aren't Ansible settings (`11-…/README.md`).
- Without a project `.ansible-lint`, ansible-lint takes the Git root as the
  project and can't resolve its collections (`11-…/README.md`).
- ade's default isolation rewrites `collections_path` in `ansible.cfg`, and it
  exits 2 for a missing system package from `bindep.txt` (`12-…/expected-demo.txt`).

## Testing patterns worth reusing

| To… | How | Where |
|---|---|---|
| Show a change and its effect in review | two commits: the tool's output, then the fixes; `git show` lists them | `03-…`, `08-…`, `11-…` |
| Keep a resolution table stable | `--exclude-newer` on every resolve, output compared with an expected file | `02-…/constraints/`, `05-…/` |
| Check a lock still matches its input in CI | regenerate it and fail on `git diff` | `.github/workflows/locks.yml`, `ee.yml`, `devserver.yml` |
| Test a server playbook without a VM | a systemd container, the `community.docker.docker` connection, a second run expecting `changed=0` | `09-shared-dev-server-for-vscode-remote-ssh/test/` |
| Check a result as the user who'll have it | a script run with `docker exec -u` as that user | `09-…/test/check-as-developer.sh` |
| Show what a tool edits without touching the example | run it in a scratch copy made a git repository, print the diffs | `12-…/demo.sh`, `10-…/reproduce-fix.sh` |
