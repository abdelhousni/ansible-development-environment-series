# Part 3: Building an execution environment from a locked requirements file

Example for [Building an Ansible execution environment from a locked requirements file](https://til.housni.eu/ansible/execution-environment-from-a-locked-requirements-file.html).

There are two commits:
- **The first** is the entry's typical first `execution-environment.yml`: `fedora:latest`, ansible-core 2.15.9, and ansible-runner and `community.general` without versions. ansible-builder 3.1.1 fails on it with `/usr/bin/python3 is not an executable`, because the Fedora image has no Python.
- **The second** locks every input. `git show` on it lists the changes.

| File | What it pins |
|---|---|
| [`execution-environment.yml`](execution-environment.yml) | The base image by digest, Python from the image, ansible-core and ansible-runner with `==` |
| [`requirements.in`](requirements.in) | Nothing: the Python packages you ask for, with ranges |
| [`requirements.txt`](requirements.txt) | Every Python package, compiled for the image's Python 3.14 |
| [`requirements.yml`](requirements.yml) | Both collections with `==`, including `community.general`'s own dependency |
| [`bindep.txt`](bindep.txt) | Nothing: system packages come from Fedora's repositories at build time |
| [`site.yml`](site.yml) | A playbook that prints ansible-core's version and a `community.general.json_query` result |

## The base image comes from registry.fedoraproject.org

The entry pinned `quay.io/fedora/fedora:44@sha256:8938dce…`. A day later that
reference no longer pulled: `no such manifest`.
- **Why:** quay.io re-points the `44` tag to a new build every morning, and it stopped serving the previous build by its digest once the tag moved.
- **What else serves the same builds:** `registry.fedoraproject.org/fedora` has the same builds under the same digests. On 2026-09-30 it still served all 15 daily digests from the previous two weeks.
- **What changed here:** only the registry name, so the image is byte for byte the one the entry tested.

A digest pin fails loudly when the registry drops the image, instead of
building something else. It still depends on the registry keeping it. For
production, copy the base image into a registry you control and pin that
digest.

## Build and check it

```sh
ansible-builder build -t my-ee:2.21.4
ansible-navigator run site.yml --eei my-ee:2.21.4 --pull-policy never --mode stdout
```

The playbook prints `"msg": "2.21.4 / 2"`.

## What CI checks

[`.github/workflows/ee.yml`](../.github/workflows/ee.yml) runs on every push and pull request, and weekly so a vanished base image shows up. It:
- reruns `uv pip compile` and fails if `requirements.txt` changes;
- builds the image with ansible-builder 3.1.1 and Docker;
- compares `pip list` inside the image with `requirements.txt`. The only packages allowed beyond the lock are `pip`, and `dumb-init`, which ansible-builder adds;
- checks both collection versions with `ansible-galaxy collection list`;
- runs `site.yml` in the image with ansible-navigator 26.9.0 and expects `2.21.4 / 2`.

[`ansible-lint.yml`](../.github/workflows/ansible-lint.yml) lints the example too, including `execution-environment.yml` against its schema.
