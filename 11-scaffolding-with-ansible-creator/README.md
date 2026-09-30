# Part 11: scaffolding with ansible-creator

The example for
[Scaffolding with ansible-creator](https://til.housni.eu/ansible/scaffolding-with-ansible-creator.html).
The first commit is the untouched output of ansible-creator 26.9.0:

```sh
ansible-creator init playbook myorg.webstack 11-scaffolding-with-ansible-creator --exclude devfile ai
ansible-creator add resource role webserver collections/ansible_collections/myorg/webstack
```

The second commit applies what the entry recommends; `git show` on it is the
whole list:

- **`ansible.cfg`:**
  - removes `host_vars_inventory` and `group_vars_inventory`, which aren't Ansible settings;
  - removes `verbosity = 2` and the `remote_user = myuser` placeholder;
  - adds `collections_path = ./collections`, so `ansible-doc` finds the project's roles.
- **`ansible-navigator.yml`:** names an execution environment by digest, with `pull: policy: missing`. Replace it with yours.
- **`collections/requirements.yml`:** only `cisco.ios`, which `network_playbook.yml` uses, pinned.
- **`site.yml`:** also calls the added role, `myorg.webstack.webserver`.
- **`.ansible-lint`:** added, with `profile: production`. ansible-lint takes its project directory from the nearest `.ansible-lint`, or else the Git root; without this file, inside this repository it would look for `collections/requirements.yml` at the repository root and fail to resolve `cisco.ios`.
- **`.github/`:** removed. Its workflow called a reusable workflow at `@main` that installs an unversioned ansible-lint. The repository root's pinned workflow lints this directory instead.

## Try it

```sh
ansible-playbook site.yml
ansible-doc -t role myorg.webstack.webserver
ansible-navigator run site.yml    # runs in the EE; needs Podman or Docker
```
