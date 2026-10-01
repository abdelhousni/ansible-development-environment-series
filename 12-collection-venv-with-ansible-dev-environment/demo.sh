#!/usr/bin/env bash
# Run the entry's ade steps in a scratch copy of this directory, and print
# what each one did. Needs ade (ansible-dev-environment 26.9.0) and uv on
# PATH, and Python 3.12. The committed files are left untouched.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp -r "$here/." "$work/"
cd "$work"
git init -q .
git add -A
git -c user.name=demo -c user.email=demo@example.com commit -qm before

versions() {  # print the locked packages' versions in a venv
  uv pip list --python "$1/bin/python" 2>/dev/null \
    | awk '$1 ~ /^(ansible-core|boto3|botocore|aiobotocore|jmespath)$/ {print "  " $1, $2}'
}

echo "== ade install -r requirements.yml, with UV_CONSTRAINT=constraints.txt"
UV_CONSTRAINT=$work/constraints.txt ade install -r requirements.yml --venv .venv -p 3.12 --no-seed --no-ansi \
  </dev/null >install.log 2>&1
versions .venv
ade list --venv .venv --no-ansi 2>/dev/null | awk '$1 == "amazon.aws" {print "  collection", $1, $2}'
echo "  ansible.cfg: $(git diff --no-color -U0 -- ansible.cfg | grep -E '^[-+]collections_path' | paste -sd' ')"

echo "== ade install -e . in collection/"
cd collection
rc=0
UV_CONSTRAINT=$work/constraints.txt ade install -e . --venv .venv -p 3.12 --no-seed --no-ansi \
  </dev/null >install.log 2>&1 || rc=$?
echo "  exit code $rc"
grep -A1 '^Warning: Required system packages are missing' install.log | sed 's/^/  /'
versions .venv
echo "  galaxy.yml build_ignore: $(git diff --no-color -U0 -- galaxy.yml | grep -E '^\+ +- ' | sed 's/^+ *- //' | paste -sd' ')"

filter() {
  PATH="$PWD/.venv/bin:$PATH" ansible localhost -m ansible.builtin.debug \
    -a "msg={{ 'ade' | myorg.tools.sample_filter }}" </dev/null 2>/dev/null \
    | grep -o '"msg": "[^"]*"'
}
echo "  filter before the edit: $(filter)"
sed -i 's/"Hello, "/"Hi, "/' plugins/filter/sample_filter.py
echo "  filter after the edit:  $(filter)"
