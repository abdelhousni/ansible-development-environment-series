#!/usr/bin/env bash
# Run inside the test server as a developer (alice), after the playbook.
# Each check prints one line; any failure stops the script.
set -euo pipefail

ee=ghcr.io/ansible-community/community-ee-base@sha256:9f2836592ab92794e8b1982311d504ba3c28a2c09b3f8de221ca3564842c0902

# /etc/profile.d/adt.sh puts the shared venv on PATH, once.
count=$(tr ':' '\n' <<<"$PATH" | grep -cx /opt/adt/bin)
[[ $count == 1 ]] || { echo "/opt/adt/bin is on PATH $count times"; exit 1; }
echo "PATH has /opt/adt/bin once"
adt --version | grep -E '^ansible-core +2\.21\.4$'

# Rootless Podman sees the shared store, and finds the EE there.
podman info --format '{{json .Store.GraphOptions}}' | grep -F /var/lib/ee-shared
podman image exists "$ee" && echo "EE found through the shared store"

# ansible-navigator runs the playbook in that EE without pulling a copy.
cd ~/project
ansible-navigator run site.yml 2>&1 | tee /tmp/run.txt
grep -F '"msg": "ansible-core 2.21.3"' /tmp/run.txt
echo "own image storage: $(du -sh ~/.local/share/containers/storage | cut -f1)"

# The machine settings file points the Ansible extension at the shared venv.
grep -F '"/opt/adt/bin/python"' ~/.vscode-server/data/Machine/settings.json
