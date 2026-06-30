#!/usr/bin/env bash

# claude.sh - Claude Code Adapter Module (Graceful Unsupported Target)

claude_detect_cli() {
    if command -v claude &>/dev/null || [ -d "$HOME/.claude" ] || [ "${MOCK_CLAUDE_INSTALLED}" = "1" ]; then
        return 0
    fi
    return 1
}

claude_get_skill_directory() {
    # Returns empty or unsupported
    echo ""
}

claude_install_skill() {
    log_error "[Claude Code] Installation aborted. Claude Code does not natively support loading custom markdown skills from a modular system directory."
    log_info "[Claude Code] Recommendation: In Claude Code, custom agent behaviors should be added as system prompt presets or configured inside ~/.claude.json."
    return 1
}

claude_remove_skill() {
    log_error "[Claude Code] Uninstallation aborted. No custom skill directory exists for Claude Code."
    return 1
}

claude_reload_cli() {
    return 0
}

claude_doctor() {
    log_warn "[Claude Code] Claude Code is detected but does not support modular custom skill directories. Settings are defined inside ~/.claude.json."
    return 0
}

claude_validate() {
    return 1
}
