#!/usr/bin/env bash
# Reproduce the entry's --fix table on legacy/site.yml, then show what
# write_list in .ansible-lint does to a plain ansible-lint run.
# Prints, per lint run: <case> <step> <failures> <warnings> <file changed?> <exit code>,
# and per --fix pass: <case> fix-<n> <file changed?>
set -euo pipefail

lint=${ANSIBLE_LINT:-ansible-lint}
here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cd "$work"
git init -q .

run() {  # run ansible-lint, print the counts, whether the file changed, and the exit code
  local case=$1 step=$2; shift 2
  local before rc=0 out failures warnings changed
  before=$(md5sum < "$file")
  out=$("$lint" "$@" "$file" </dev/null 2>&1) || rc=$?
  read -r failures warnings < <(printf '%s\n' "$out" | sed 's/\x1b\[[0-9;]*m//g' \
    | grep -oE '(Failed|Passed): [0-9]+ failure\(s\), [0-9]+ warning\(s\)' \
    | grep -oE '[0-9]+' | paste -sd' ')
  changed=unchanged
  [[ $before == "$(md5sum < "$file")" ]] || changed=changed
  echo "$case $step $failures $warnings $changed rc=$rc"
}

# 1. No config file: a plain run, then --fix four times, as successive saves would.
file=site.yml
cp "$here/legacy/site.yml" "$file"
run no-config lint
for i in 1 2 3 4; do
  before=$(md5sum < "$file")
  "$lint" --fix "$file" </dev/null >/dev/null 2>&1 || true
  changed=unchanged
  [[ $before == "$(md5sum < "$file")" ]] || changed=changed
  echo "no-config fix-$i $changed"
  run no-config lint
done

# 2. write_list in .ansible-lint: a plain run, without --fix, rewrites the file.
printf -- '---\nwrite_list:\n  - formatting\n' > .ansible-lint
cp "$here/legacy/site.yml" "$file"
run write-list lint
cp "$here/legacy/site.yml" "$file"
run write-list lint-fix-none --fix=none

# 3. The same, on a playbook whose only problems are formatting ones.
file=formatting-only.yml
printf -- '---\n- name: Show a message\n  hosts: localhost\n  gather_facts: false\n  tasks:\n  - name: Print it\n    debug:\n      msg: hello\n' > "$file"
run write-list formatting-only
