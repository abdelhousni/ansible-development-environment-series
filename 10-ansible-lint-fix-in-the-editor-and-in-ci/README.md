# Part 10: `--fix` in the editor, the same ansible-lint in CI

Example for [Linting Ansible before it reaches Git: `--fix` in the editor, the same ansible-lint in CI](https://til.housni.eu/ansible/ansible-lint-fix-in-the-editor-and-in-ci.html).

| File | What it is |
|---|---|
| [`legacy/site.yml`](legacy/site.yml) | The entry's sample playbook in legacy style: 19 failures and 2 warnings |
| [`site.yml`](site.yml) | The same playbook after `--fix` and the four fixes that need a person |
| [`.ansible-lint`](.ansible-lint) | `profile: production`, `write_list: [formatting]`, and `legacy/` excluded |
| [`.vscode/settings.json`](.vscode/settings.json) | `ansible.validation.lint.autoFixOnSave: true` for the Ansible extension |
| [`requirements.in`](requirements.in), [`requirements.txt`](requirements.txt) | `ansible-lint==26.9.0`, locked with hashes for Python 3.12 |
| [`reproduce-fix.sh`](reproduce-fix.sh), [`expected-fix.txt`](expected-fix.txt) | Reruns the entry's `--fix` table, and shows what `write_list` does |

## The `--fix` table

```sh
pip install --require-hashes -r requirements.txt
./reproduce-fix.sh
```

The script copies `legacy/site.yml` into an empty git repository with no
`.ansible-lint`, lints it, and runs `ansible-lint --fix` four times, as
successive saves would. It lints again after each pass:

```text
no-config lint 19 2 unchanged rc=2
no-config fix-1 changed
no-config lint 6 1 unchanged rc=2
no-config fix-2 changed
no-config lint 4 1 unchanged rc=2
no-config fix-3 changed
no-config lint 4 0 unchanged rc=2
no-config fix-4 unchanged
no-config lint 4 0 unchanged rc=2
```

The four failures left are the ones `site.yml` fixes by hand:
- name the play;
- name the `debug` task;
- use `ansible.builtin.systemd` instead of `command: systemctl`, which also removes the need for `changed_when`.

## `write_list` in `.ansible-lint` applies fixes on every run

The rest of the output uses a `.ansible-lint` with `write_list: [formatting]`:

```text
write-list lint 13 2 changed rc=2
write-list lint-fix-none 13 2 changed rc=2
write-list formatting-only 0 0 changed rc=8
```

- **Every run fixes.** A plain `ansible-lint`, without `--fix`, rewrote the file and printed `Modified 1 file.` The formatting violations it fixed aren't counted, which is why it reports 13 failures, not 19.
- **The command line can't turn it off.** `--fix=none` rewrote the file too. ansible-lint 26.9.0's `merge_fix_list_config` uses the file's `write_list` whenever the file sets one.
- **CI still fails, but reads oddly.** On a playbook whose only problems are formatting, the run printed `Passed: 0 failure(s)`, rewrote the file, and exited with 8, `FIXED_VIOLATIONS`. So a pipeline still goes red when committed files aren't formatted.

The Ansible extension passes the same `.ansible-lint` with `-c`, and lints
each file when it's opened. So with `write_list` in the file, opening a file
should apply the formatting fixes even with `autoFixOnSave` off. That follows
from the command-line runs above; it wasn't tested in the editor.

`site.yml` is already formatted, so linting this directory changes nothing
and exits 0.

## What CI checks

[`.github/workflows/lint-fix.yml`](../.github/workflows/lint-fix.yml) installs `requirements.txt` with `--require-hashes` on Python 3.12, on every push and pull request. It then:
- reruns `reproduce-fix.sh` and compares its output with `expected-fix.txt`;
- lints this directory with the locked ansible-lint, and fails if the run changed any file.

The repository's [`ansible-lint.yml`](../.github/workflows/ansible-lint.yml) lints it too, with the ansible-lint action from part 10.
