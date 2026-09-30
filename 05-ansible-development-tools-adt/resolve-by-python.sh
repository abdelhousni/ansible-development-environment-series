#!/usr/bin/env bash
# Resolve ansible-dev-tools for each Python version, against PyPI as it was
# on the day the entry was tested. Prints the entry's table as plain text.
set -euo pipefail

uv=${UV:-uv}
cutoff=2026-09-30T00:00:00Z

echo "python adt ansible-core packages"
for py in 3.9 3.10 3.11 3.12 3.13 3.14; do
  if out=$(echo ansible-dev-tools | "$uv" pip compile - --python-version "$py" \
      --exclude-newer "$cutoff" --no-header --quiet 2>&1); then
    adt=$(grep -m1 '^ansible-dev-tools==' <<<"$out" | cut -d= -f3)
    core=$(grep -m1 '^ansible-core==' <<<"$out" | cut -d= -f3)
    count=$(grep -c '^[a-z0-9].*==' <<<"$out")
    echo "$py $adt $core $count"
  elif grep -q 'No solution found' <<<"$out"; then
    echo "$py none none 0"
  else
    echo "$out" >&2
    exit 1
  fi
done
