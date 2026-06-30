#!/usr/bin/env bash

# list-skills.sh - Lists all registered skills grouped by category

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/common.sh
source "${PROJECT_ROOT}/lib/common.sh"
# shellcheck source=lib/manifest.sh
source "${PROJECT_ROOT}/lib/manifest.sh"

show_help() {
    echo "AI Skills List CLI"
    echo "Usage: $0 [options]"
    echo ""
    echo "Common Options:"
    echo "  --verbose   Show detailed execution logs"
    echo "  --version   Print version information"
    echo "  -h, --help  Show this help menu"
    exit 0
}

if [ "$HELP" = "true" ]; then
    show_help
fi

list_category() {
    local category="$1"
    local title="$2"
    
    echo "$title"
    echo "--------"
    
    local skills
    skills=$(get_manifest_skills)
    local count=0
    for skill in $skills; do
        local cat
        cat=$(get_skill_field "$skill" "category")
        if [ "$cat" = "$category" ]; then
            echo "$skill"
            count=$((count + 1))
        fi
    done
    if [ "$count" -eq 0 ]; then
        echo "(None)"
    fi
    echo ""
}

main() {
    local skills
    skills=$(get_manifest_skills)
    local total_count
    total_count=$(echo "$skills" | wc -w)
    
    list_category "core" "Core"
    list_category "engineering" "Engineering"
    list_category "workflow" "Workflow"
    list_category "agent" "Agents"
    
    log_bold "========================================"
    log_success "Total registered skills: $total_count"
    log_bold "========================================"
}

main "$@"
