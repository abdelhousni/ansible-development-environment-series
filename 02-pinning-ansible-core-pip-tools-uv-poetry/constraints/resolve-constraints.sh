#!/usr/bin/env bash
# Resolve ansible-core under each constraint with uv, for Python 3.13, against
# PyPI as it was on the day the entry was tested. Prints one line per
# constraint: the version it resolved to, or "parse-error".
set -euo pipefail

uv=${UV:-uv}
cutoff=2026-09-30T00:00:00Z

constraints=(
  "==2.21.4"
  ">=2.21.0,<2.22"
  "~=2.21.0"
  "~2.21.0"
  "^2.21.0"
  "~=2.21"
  "~=2.15"
  "~=2.15.9"
  ">=2.15.0,<2.16.0"
)

for c in "${constraints[@]}"; do
  if out=$(echo "ansible-core$c" | "$uv" pip compile - --python-version 3.13 \
      --exclude-newer "$cutoff" --no-header --quiet 2>&1); then
    echo "$c $(grep -m1 '^ansible-core==' <<<"$out" | cut -d= -f3)"
  elif grep -q "Couldn't parse requirement" <<<"$out"; then
    echo "$c parse-error"
  else
    echo "$out" >&2
    exit 1
  fi
done
