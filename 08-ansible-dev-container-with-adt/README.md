# Part 8: An Ansible Dev Container

Example for [An Ansible Dev Container: choosing the scaffolded config, Podman, and the EE navigator falls back to](https://til.housni.eu/ansible/ansible-dev-container-with-adt.html).

There are two commits:
- **The first** holds the files as `ansible-creator init playbook` 26.9.0 generates them: three `devcontainer.json` files on `ghcr.io/ansible/community-ansible-dev-tools:latest`, and an `ansible-navigator.yml` that names no execution environment (EE).
- **The second** pins both images, and adds `site.yml`. `git show` on it lists the changes.

| File | For |
|---|---|
| [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json) | GitHub Codespaces |
| [`.devcontainer/docker/devcontainer.json`](.devcontainer/docker/devcontainer.json) | Docker Desktop or Docker Engine |
| [`.devcontainer/podman/devcontainer.json`](.devcontainer/podman/devcontainer.json) | Podman, with `dev.containers.dockerPath` set to `podman` in your user settings |
| [`ansible-navigator.yml`](ansible-navigator.yml) | The EE by digest, with pull policy `missing` |
| [`site.yml`](site.yml) | Prints the ansible-core that runs it |
| [`tools/`](tools/) | `package.json` and `package-lock.json` for `@devcontainers/cli` 0.89.0, the Dev Container command-line tool |

VS Code looks for `.devcontainer/` at the root of the folder you open, so
open this directory, not the whole repository, and pick a configuration.

## What the second commit changes

- **The Dev Container image, by digest:** `ghcr.io/ansible/community-ansible-dev-tools@sha256:775c81d…`, the ADT image of 2026-09-29, instead of `latest`. Everyone then gets the same tools.
- **The EE, by digest:** without an `execution-environment.image`, navigator falls back to `ghcr.io/ansible/community-ansible-dev-tools:latest`, the 2 GB ADT image itself, and pulls it again on every run. The example names the EE from part 7, `ghcr.io/ansible-community/community-ee-base@sha256:9f28365…`, with `pull: policy: missing`.

## Start it without VS Code

```sh
npm ci --prefix tools --ignore-scripts
export PATH="$PWD/tools/node_modules/.bin:$PATH"
devcontainer up --workspace-folder . --config .devcontainer/docker/devcontainer.json
devcontainer exec --workspace-folder . --config .devcontainer/docker/devcontainer.json adt --version
devcontainer exec --workspace-folder . --config .devcontainer/docker/devcontainer.json \
  ansible-navigator run site.yml --mode stdout
```

The playbook runs in the EE, nested inside the Dev Container with its
Podman, and prints `"msg": "ansible-core 2.21.3"`: the EE's version, not
the 2.21.4 of the Dev Container's own tools. The logs and playbook artifacts
go to `.logs/`, which `.gitignore` excludes.

## What CI checks

[`.github/workflows/devcontainer.yml`](../.github/workflows/devcontainer.yml) installs `@devcontainers/cli` from `tools/package-lock.json` and starts the Docker configuration on every push and pull request. It then checks:
- `adt --version` inside shows ansible-core 2.21.4;
- navigator's effective EE is the pinned image;
- `site.yml` run in that EE prints ansible-core 2.21.3.

The Codespaces and Podman configurations aren't started in CI.
