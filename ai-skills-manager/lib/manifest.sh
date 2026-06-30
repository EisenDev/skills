#!/usr/bin/env bash

# manifest.sh - Database manifest parser for skill-manifest.yaml

if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/common.sh
    source "${PROJECT_ROOT}/lib/common.sh"
fi
# shellcheck source=lib/filesystem.sh
source "${PROJECT_ROOT}/lib/filesystem.sh"


# Assert manifest file exists
assert_file_exists "$MANIFEST_PATH" "Manifest not found at $MANIFEST_PATH"

# Extract all skill IDs
get_manifest_skills() {
    python3 -c "
import yaml
try:
    with open('${MANIFEST_PATH}') as f:
        data = yaml.safe_load(f)
        print(' '.join([s['id'] for s in data.get('skills', [])]))
except Exception as e:
    import sys
    print(f'Error reading manifest: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Fetch a specific field for a skill ID from the manifest
get_skill_field() {
    local skill_id="$1"
    local field="$2"
    python3 -c "
import yaml
try:
    with open('${MANIFEST_PATH}') as f:
        data = yaml.safe_load(f)
        for s in data.get('skills', []):
            if s['id'] == '${skill_id}':
                val = s.get('${field}', '')
                if isinstance(val, list):
                    print(' '.join(val))
                else:
                    print(val)
                break
except Exception as e:
    import sys
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"
}

validate_manifest_structure() {
    python3 -c "
import yaml, sys
try:
    with open('${MANIFEST_PATH}') as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict) or 'skills' not in data:
        print('Error: Manifest top-level structure must contain \"skills\" key.', file=sys.stderr)
        sys.exit(1)
    skills = data['skills']
    if not isinstance(skills, list):
        print('Error: \"skills\" must be a list of elements.', file=sys.stderr)
        sys.exit(1)
    for s in skills:
        for field in ['id', 'name', 'version', 'category', 'directory', 'supported_clis', 'install_mode']:
            if field not in s:
                print(f'Error: Skill \"{s.get(\"id\", \"unknown\")}\" is missing field: {field}', file=sys.stderr)
                sys.exit(1)
    print('OK')
except Exception as e:
    print(f'Error parsing manifest: {e}', file=sys.stderr)
    sys.exit(1)
" >/dev/null
}

