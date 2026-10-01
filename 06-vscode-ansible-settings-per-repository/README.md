# Part 6: Committing the VS Code Ansible settings with the repository

Example for [Committing the VS Code Ansible settings with the repository](https://til.housni.eu/ansible/vscode-ansible-settings-per-repository.html).

| File | What it is |
|---|---|
| [`.vscode/settings.json`](.vscode/settings.json) | The workspace settings from the entry |
| [`.vscode/extensions.json`](.vscode/extensions.json) | Recommends `redhat.ansible` |
| [`site.yml`](site.yml) | A playbook, to see the extension at work |
| [`check-settings.py`](check-settings.py), [`expected-settings.txt`](expected-settings.txt) | Checks the settings against the extension's own manifest |

Open this directory in VS Code, not the whole repository: VS Code reads
`.vscode/` from the root of the folder it opens.

## One change from the entry

The entry's EE image is a placeholder, `registry.example.com/ansible/my-ee@sha256:…`.
Here it's a real one, the EE from [part 7](../07-develop-against-the-production-execution-environment/):
`ghcr.io/ansible-community/community-ee-base@sha256:9f28365…`. Put your own
team's EE there, by digest.

## Checking the settings against the extension

```sh
./check-settings.py
```

The script downloads the released extension, `redhat.ansible` 26.8.2, from
Open VSX. It checks the file's SHA-256, then reads the extension's
`package.json`, which declares every setting with its type, default and
allowed values. It prints each setting next to its default
([`expected-settings.txt`](expected-settings.txt)):

```text
ansible.executionEnvironment.enabled: default false, set to true
ansible.executionEnvironment.image: default "ghcr.io/ansible/community-ansible-dev-tools:latest", set to "ghcr.io/ansible-community/community-ee-base@sha256:9f28…"
ansible.executionEnvironment.pull.policy: default "missing", set to "missing", allowed ['always', 'missing', 'never', 'tag']
```

It fails if an `ansible.*` setting doesn't exist, has the wrong type, or isn't
one of the allowed values. So a misspelled key such as
`ansible.validation.lintt.enabled`, which VS Code would silently ignore, turns
CI red. It also lists the extensions `redhat.ansible` pulls in, and checks
that `site.yml` opens as an Ansible file through the extension's file
patterns, with no `files.associations` needed.

## What CI checks

[`.github/workflows/vscode-settings.yml`](../.github/workflows/vscode-settings.yml) runs the script on every push and pull request, and compares its output with `expected-settings.txt`. [`ansible-lint.yml`](../.github/workflows/ansible-lint.yml) lints `site.yml`.
