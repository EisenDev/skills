#!/usr/bin/env bash

# Resolve project root path
get_project_root() {
    local target
    target=$(dirname "${BASH_SOURCE[0]}")/..
    cd "$target" && pwd
}

PROJECT_ROOT=$(get_project_root)
MANIFEST_PATH="${PROJECT_ROOT}/skill-manifest.yaml"

# Source logger library
if [ -f "${PROJECT_ROOT}/lib/logger.sh" ]; then
    # shellcheck source=lib/logger.sh
    source "${PROJECT_ROOT}/lib/logger.sh"
else
    echo "[ERROR] Logger library not found at ${PROJECT_ROOT}/lib/logger.sh" >&2
    exit 1
fi

# Assert file exists
assert_file_exists() {
    local file="$1"
    local error_msg="$2"
    if [ ! -f "$file" ]; then
        log_error "${error_msg:-File not found: $file}"
        exit 1
    fi
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    local error_msg="$2"
    if [ ! -d "$dir" ]; then
        log_error "${error_msg:-Directory not found: $dir}"
        exit 1
    fi
}

# Fetch all skill names from the manifest
get_manifest_skills() {
    python3 -c "
import yaml
try:
    with open('${MANIFEST_PATH}') as f:
        data = yaml.safe_load(f)
        print(' '.join([s['name'] for s in data.get('skills', [])]))
except Exception as e:
    import sys
    print(f'Error reading manifest: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Fetch a specific field for a skill from the manifest
get_skill_field() {
    local skill="$1"
    local field="$2"
    python3 -c "
import yaml
try:
    with open('${MANIFEST_PATH}') as f:
        data = yaml.safe_load(f)
        for s in data.get('skills', []):
            if s['name'] == '${skill}':
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

# Parse a specific frontmatter field from a skill's markdown file
parse_frontmatter_field() {
    local file="$1"
    local field="$2"
    python3 -c "
import yaml
try:
    with open('${file}') as f:
        content = f.read()
        if content.startswith('---'):
            parts = content.split('---', 2)
            if len(parts) >= 3:
                meta = yaml.safe_load(parts[1])
                val = meta.get('${field}', '')
                if isinstance(val, list):
                    print(' '.join(val))
                else:
                    print(val)
except Exception as e:
    import sys
    print(f'Error reading frontmatter in {file}: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Validate semantic version format (X.Y.Z)
validate_semver() {
    local ver="$1"
    if [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}
