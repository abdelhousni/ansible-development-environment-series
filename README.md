# Ansible development environment series: examples

Runnable examples for the **Ansible development environment** series on
[til.housni.eu](https://til.housni.eu/). Each directory belongs to one entry
of the series and is self-contained.

| Directory | Entry |
|---|---|
| [`11-scaffolding-with-ansible-creator/`](11-scaffolding-with-ansible-creator/) | [Part 11: Scaffolding with ansible-creator](https://til.housni.eu/ansible/scaffolding-with-ansible-creator.html) |

CI lints every example with the pinned ansible-lint workflow from
[part 10](https://til.housni.eu/ansible/ansible-lint-fix-in-the-editor-and-in-ci.html);
each example's own `.ansible-lint` sets its profile. GitHub only runs workflows from the repository root, so the examples keep
none of their own.
