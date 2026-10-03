#!/usr/bin/env bash
# Checks the local lab described in the README's "Local lab" section: each
# tool on PATH at the version the examples were tested with. Reports what's
# missing or different, with the command that fixes it. Changes nothing.
set -u
missing=0
ok() { printf '  ok       %s\n' "$1"; }
ko() { printf '  MISSING  %s: %s\n' "$1" "$2"; missing=1; }

# version <label> <expected> <fix> <command...>: runs the command, looks for
# the expected version in its output.
version() {
  local label=$1 expected=$2 fix=$3
  shift 3
  local out
  if ! out=$("$@" 2>&1); then
    ko "$label $expected" "$fix"
  elif grep -qF -- "$expected" <<<"$out"; then
    ok "$label $expected"
  else
    ko "$label $expected (found: $(head -1 <<<"$out"))" "$fix"
  fi
}

echo "Python:"
version "python3.12 (01, 09, 10, 12)" "3.12" "install your distribution's python3.12" python3.12 --version
version "python3.13 (02, 05)" "3.13" "install python3.13, or let uv fetch it: uv python install 3.13" python3.13 --version

echo "Python tools, each in its own environment:"
version "uv (01, 02, 03, 05, 09, 12)" "0.12.20" "python3.12 -m venv .lab && .lab/bin/pip install uv==0.12.20" uv --version
version "pip-tools (01, 02)" "7.6.1" "uv tool install pip-tools==7.6.1" pip-compile --version
version "Poetry (01, 02)" "2.5.1" "uv tool install poetry==2.5.1" poetry --version
version "ansible-core (07, 09, 11)" "2.21.4" "uv tool install ansible-core==2.21.4" ansible --version
version "ansible-builder (03)" "3.1.1" "uv tool install ansible-builder==3.1.1" ansible-builder --version
version "ansible-navigator (03, 07, 11)" "26.9.0" "uv tool install ansible-navigator==26.9.0" ansible-navigator --version
version "ansible-dev-environment (12)" "26.9.0" "uv tool install ansible-dev-environment==26.9.0" ade --version

echo "Collections:"
if ansible-galaxy collection list community.docker 2>/dev/null | grep -q '5\.3\.0'; then
  ok "community.docker 5.3.0 (09)"
else
  ko "community.docker 5.3.0 (09)" "ansible-galaxy collection install community.docker:==5.3.0"
fi

echo "Containers and Node.js:"
if ! command -v docker >/dev/null; then
  ko "docker CLI (03, 07, 08, 09, 11)" "install Docker Engine or Docker Desktop"
elif ! docker info >/dev/null 2>&1; then
  ko "Docker daemon (03, 07, 08, 09, 11)" "start it (systemctl start docker), and check your user can reach it"
else
  ok "Docker daemon $(docker version --format '{{.Server.Version}}' 2>/dev/null) (03, 07, 08, 09, 11)"
fi
version "Node.js (08)" "v" "install Node.js 22 with npm" node --version
version "npm (08)" "." "install npm with Node.js" npm --version

echo "Not checked: VS Code with the redhat.ansible extension (06, 08), optional."
exit $missing
