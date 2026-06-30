#!/usr/bin/env bash

# codex.sh - Codex CLI Adapter Module (Graceful Unsupported Target)

codex_detect_cli() {
    if command -v codex &>/dev/null || [ -d "$HOME/.codex" ] || [ "${MOCK_CODEX_INSTALLED}" = "1" ]; then
        return 0
    fi
    return 1
}

codex_get_skill_directory() {
    echo ""
}

codex_install_skill() {
    log_error "[Codex CLI] Installation aborted. Codex CLI does not natively support loading custom markdown skills from a modular directory."
    log_info "[Codex CLI] Recommendation: Custom plugin utilities are managed using the Codex CLI JS/TS plugin interface config."
    return 1
}

codex_remove_skill() {
    log_error "[Codex CLI] Uninstallation aborted. No custom skill directory exists for Codex CLI."
    return 1
}

codex_reload_cli() {
    return 0
}

codex_doctor() {
    log_warn "[Codex CLI] Codex CLI is detected but does not support modular custom skill directories natively."
    return 0
}

codex_validate() {
    return 1
}
