#!/usr/bin/env bash

# Source dependencies
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=lib/utils.sh
    source "${PROJECT_ROOT}/lib/utils.sh"
fi

validate_skillset_content() {
    log_info "Validating skillset directories and metadata..."
    
    # Check required folders exist
    assert_dir_exists "${PROJECT_ROOT}/skillset/01-core" "Core folder missing"
    assert_dir_exists "${PROJECT_ROOT}/skillset/02-engineering" "Engineering folder missing"
    assert_dir_exists "${PROJECT_ROOT}/skillset/03-workflows" "Workflows folder missing"
    assert_dir_exists "${PROJECT_ROOT}/skillset/04-agents" "Agents folder missing"

    # Use python for deep metadata and dependency validation
    local validation_result
    validation_result=$(python3 -c "
import yaml, os, sys

manifest_path = '${MANIFEST_PATH}'
skillset_dir = '${PROJECT_ROOT}/skillset'

try:
    with open(manifest_path) as f:
        manifest = yaml.safe_load(f)
except Exception as e:
    print(f'Error reading manifest: {e}')
    sys.exit(1)

skills_list = manifest.get('skills', [])
skills_map = {s['name']: s for s in skills_list}

# 1. Validate frontmatter of each file and compare with manifest
for s in skills_list:
    name = s['name']
    cat = s['category']
    folder = s['directory']
    version = s['version']
    
    md_path = os.path.join(skillset_dir, folder, f'{name}.md')
    if not os.path.isfile(md_path):
        print(f'Error: Markdown file for {name} does not exist at {md_path}')
        sys.exit(1)
        
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if not content.startswith('---'):
        print(f'Error: File {md_path} does not start with YAML frontmatter separator \"---\"')
        sys.exit(1)
        
    parts = content.split('---', 2)
    if len(parts) < 3:
        print(f'Error: Invalid YAML frontmatter formatting in {md_path}')
        sys.exit(1)
        
    try:
        meta = yaml.safe_load(parts[1])
    except Exception as e:
        print(f'Error parsing YAML frontmatter in {md_path}: {e}')
        sys.exit(1)
        
    # Check frontmatter fields
    if not meta:
        print(f'Error: Empty frontmatter in {md_path}')
        sys.exit(1)
        
    for field in ['name', 'category', 'version', 'dependencies']:
        if field not in meta:
            print(f'Error: Missing frontmatter field \"{field}\" in {md_path}')
            sys.exit(1)
            
    if meta['name'] != name:
        print(f'Error: Frontmatter name \"{meta[\"name\"]}\" does not match manifest name \"{name}\" in {md_path}')
        sys.exit(1)
        
    if meta['category'] != cat:
        print(f'Error: Frontmatter category \"{meta[\"category\"]}\" does not match manifest category \"{cat}\" in {md_path}')
        sys.exit(1)
        
    if meta['version'] != version:
        print(f'Error: Frontmatter version \"{meta[\"version\"]}\" does not match manifest version \"{version}\" in {md_path}')
        sys.exit(1)

# 2. Dependency Graph Validation (Cycle detection & Missing dependencies)
graph = {}
for s in skills_list:
    name = s['name']
    deps = s.get('dependencies', [])
    graph[name] = deps

# Verify all dependency names exist in skills list
for name, deps in graph.items():
    for dep in deps:
        if dep not in skills_map:
            print(f'Error: Skill \"{name}\" depends on \"{dep}\" which is not defined in the manifest!')
            sys.exit(1)

# Cycle detection via DFS
visited = {} # state: 0=unvisited, 1=visiting, 2=visited
def has_cycle(node):
    visited[node] = 1 # visiting
    for neighbor in graph.get(node, []):
        if visited.get(neighbor, 0) == 1:
            return True
        elif visited.get(neighbor, 0) == 0:
            if has_cycle(neighbor):
                return True
    visited[node] = 2 # visited
    return False

for skill_name in graph:
    if visited.get(skill_name, 0) == 0:
        if has_cycle(skill_name):
            print(f'Error: Circular dependency detected involving skill \"{skill_name}\"')
            sys.exit(1)

print('OK')
" 2>&1)

    if [ "$validation_result" != "OK" ]; then
        log_error "Content validation failed: $validation_result"
        return 1
    fi

    log_success "All skill files, frontmatter records, and dependencies are verified."
    return 0
}
