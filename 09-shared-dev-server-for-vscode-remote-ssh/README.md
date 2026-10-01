# Part 9: A shared Ansible dev server for VS Code Remote-SSH

Example for [A shared Ansible dev server for VS Code Remote-SSH, built with Ansible](https://til.housni.eu/ansible/shared-dev-server-for-vscode-remote-ssh.html).

| File | What it is |
|---|---|
| [`devserver.yml`](devserver.yml) | The entry's playbook: Podman, one locked ADT venv, a shared EE image store, and per-developer settings |
| [`files/adt-requirements.txt`](files/adt-requirements.txt), [`requirements.in`](requirements.in) | The ADT lock the playbook installs, for Python 3.12 on RHEL 9's glibc |
| [`test/`](test/) | What CI uses to try it: a Rocky Linux 9 container booted with systemd, an inventory, and a check run as a developer |

## Run it against your servers

Put the servers in a `devservers` group of your own inventory, set
`dev_users` in the playbook, and run:

```sh
ansible-playbook -i inventory.yml devserver.yml
```

The users must exist already. The playbook checks they have subordinate IDs
for rootless Podman, and fails if one doesn't.

## The lock

```sh
uv pip compile --python-version 3.12 --python-platform x86_64-manylinux_2_34 \
  --generate-hashes --exclude-newer 2026-09-30T00:00:00Z requirements.in -o files/adt-requirements.txt
```

`--exclude-newer` makes uv ignore anything uploaded to PyPI after the entry
was tested, so the lock holds the same 69 packages, hashes included, as the
entry's test. Drop it, or move the date, to upgrade.

## What CI checks

[`.github/workflows/devserver.yml`](../.github/workflows/devserver.yml) runs on every push and pull request:
1. It checks that `files/adt-requirements.txt` still matches `requirements.in`.
2. It builds the test server from [`test/Containerfile`](test/Containerfile): Rocky Linux 9, pinned by digest, booted with systemd, with two users, alice and bob.
3. It runs the playbook, then runs it again and expects `changed=0`.
4. As alice, [`test/check-as-developer.sh`](test/check-as-developer.sh) checks that:
   - `/opt/adt/bin` is on her login shell's `PATH` once, and `adt --version` shows ansible-core 2.21.4;
   - her rootless Podman lists `/var/lib/ee-shared` as an additional image store, and finds the EE there;
   - `ansible-navigator run`, from [`test/project/`](test/project/), runs a playbook in that EE and gets its ansible-core, 2.21.3, without pulling her own copy;
   - her VS Code Server machine settings point the Ansible extension at `/opt/adt/bin/python`.

Four steps are there only for the test, as in the entry's own test notes:
- **The Docker connection** (`test/inventory.yml`): CI reaches the container with `community.docker.docker` instead of SSH.
- **`ansible_become_method: su`** in the same inventory: the connection is already root, and `sudo`'s PAM check failed in the container.
- **`dnf reinstall shadow-utils pam`** in the Containerfile: the base image has lost file capabilities. `newuidmap` and `newgidmap` need theirs for rootless Podman. PAM's `unix_chkpwd` needs its own to read `/etc/shadow`; without it, systemd couldn't start alice's lingering user session. A RHEL 9 VM has them.
- **`kernel.apparmor_restrict_unprivileged_userns=0`** on the runner: Ubuntu 24.04 blocks the user namespaces rootless Podman needs, even inside a privileged container. This is a setting of GitHub's runner, not of the dev server.
