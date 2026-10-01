#!/usr/bin/env python3
"""Check .vscode/ against the Ansible extension's own manifest.

Downloads the released extension (pinned by version and SHA-256) from Open
VSX, reads its package.json, and prints, for every setting in
.vscode/settings.json, the extension's default and the value committed here.
Fails if an ansible.* setting doesn't exist, has the wrong type or isn't one
of the allowed values, or if site.yml wouldn't open as an Ansible file.
"""

import fnmatch
import hashlib
import io
import json
import sys
import urllib.request
import zipfile
from pathlib import Path

VERSION = "26.8.2"
SHA256 = "ebd4cb3c674a764cd41cbd249bd4ab9588d958360257eaf6c9168afbccda14fa"
URL = f"https://open-vsx.org/api/redhat/ansible/{VERSION}/file/redhat.ansible-{VERSION}.vsix"
TYPES = {"boolean": bool, "string": str, "number": (int, float), "array": list, "object": dict}

here = Path(__file__).parent
errors = []

with urllib.request.urlopen(URL) as response:  # noqa: S310 - fixed https URL
    vsix = response.read()
if hashlib.sha256(vsix).hexdigest() != SHA256:
    sys.exit(f"checksum mismatch for {URL}")
manifest = json.loads(zipfile.ZipFile(io.BytesIO(vsix)).read("extension/package.json"))

properties = {}
configuration = manifest["contributes"]["configuration"]
for section in configuration if isinstance(configuration, list) else [configuration]:
    properties.update(section.get("properties", {}))

print(f"redhat.ansible {manifest['version']}")
settings = json.loads((here / ".vscode/settings.json").read_text())
for key, value in settings.items():
    if not key.startswith("ansible."):
        print(f"{key}: VS Code core setting, set to {json.dumps(value)}")
        continue
    spec = properties.get(key)
    if spec is None:
        errors.append(f"{key} isn't a setting of redhat.ansible {VERSION}")
        continue
    expected = TYPES.get(spec.get("type"))
    if expected and not isinstance(value, expected):
        errors.append(f"{key} should be a {spec['type']}")
    if "enum" in spec and value not in spec["enum"]:
        errors.append(f"{key}: {value!r} isn't one of {spec['enum']}")
    line = f"{key}: default {json.dumps(spec.get('default'))}, set to {json.dumps(value)}"
    if "enum" in spec:
        line += f", allowed {spec['enum']}"
    print(line)

print(f"extensionDependencies: {manifest.get('extensionDependencies')}")
recommendations = json.loads((here / ".vscode/extensions.json").read_text())["recommendations"]
if "redhat.ansible" not in recommendations:
    errors.append("extensions.json doesn't recommend redhat.ansible")

ansible = next(lang for lang in manifest["contributes"]["languages"] if lang["id"] == "ansible")
patterns = ansible.get("filenamePatterns", [])
names = ansible.get("filenames", [])
for playbook in sorted(here.glob("*.yml")):
    is_ansible = playbook.name in names or any(fnmatch.fnmatch(f"x/{playbook.name}", p) for p in patterns)
    print(f"{playbook.name}: {'opens as Ansible' if is_ansible else 'opens as plain YAML'}")
    if playbook.name == "site.yml" and not is_ansible:
        errors.append("site.yml wouldn't open as an Ansible file")

for error in errors:
    print(f"ERROR: {error}", file=sys.stderr)
sys.exit(1 if errors else 0)
