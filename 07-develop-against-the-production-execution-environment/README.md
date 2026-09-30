# Part 7: Running playbooks locally in the execution environment production uses

Example for [Running playbooks locally in the execution environment production uses](https://til.housni.eu/ansible/develop-against-the-production-execution-environment.html).

| File | What it is |
|---|---|
| [`ansible-navigator.yml`](ansible-navigator.yml) | The EE by digest, pull policy `missing`, `DEMO_TOKEN` passed through, stdout mode, no artifacts |
| [`ansible.cfg`](ansible.cfg), [`inventory.ini`](inventory.ini) | The project's configuration, which the EE picks up |
| [`where.yml`](where.yml) | Prints the ansible-core version, the playbook directory, the config file and two environment variables |
| [`needs-general.yml`](needs-general.yml) | Uses `community.general.json_query`, which the EE doesn't have |

The EE is `ghcr.io/ansible-community/community-ee-base`, pinned by digest. It
has ansible-core 2.21.3 and three collections: `ansible.posix`,
`ansible.utils` and `ansible.windows`. ansible-navigator 26.9.0 runs the
playbooks, and it reads `ansible-navigator.yml` from this directory.

## What runs where

```sh
DEMO_TOKEN=abc123 OTHER_VAR=xyz ansible-navigator run where.yml
```

```text
"ansible-core 2.21.3",
"playbook_dir <this directory>",
"config <this directory>/ansible.cfg",
"DEMO_TOKEN=abc123",
"OTHER_VAR=unset"
```

- **The ansible-core version is the EE's:** 2.21.3, whatever the host has.
- **The project is mounted at the same path**, so `ansible.cfg` applies.
- **Only `DEMO_TOKEN` gets through:** it's listed under `environment-variables.pass`, and `OTHER_VAR` isn't.

## The EE decides which collections exist

```sh
ansible-navigator run needs-general.yml
```

This fails with `No filter named 'community.general.json_query'`: the EE
doesn't have the collection. Install it next to the playbook, and the next
run fails one step later:

```sh
ansible-galaxy collection install community.general:==13.4.0 -p ./collections
ansible-navigator run needs-general.yml
```

```text
You need to install "jmespath" prior to running json_query filter
```

A collection in `./collections` brings its code, not its Python
dependencies. `collections/` is in `.gitignore`: the fix is to build the
collection into the EE, as in part 3.

## What CI checks

[`.github/workflows/navigator.yml`](../.github/workflows/navigator.yml) installs ansible-navigator 26.9.0 and runs all three steps above on every push and pull request:
- `where.yml` must print the five lines above;
- `needs-general.yml` must fail with the missing filter;
- after installing the collection, it must fail with the jmespath message, and `ansible-navigator collections` must list `community.general`.
