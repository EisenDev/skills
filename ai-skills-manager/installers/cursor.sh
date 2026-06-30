#!/usr/bin/env bash

# cursor.sh - Cursor CLI Adapter Module (Graceful Unsupported Target)

cursor_detect_cli() {
    if command -v cursor &>/dev/null || [ -d "$HOME/.cursor" ] || [ "${MOCK_CURSOR_INSTALLED}" = "1" ]; then
        return 0
    fi
    return 1
}

cursor_get_skill_directory() {
    echo ""
}

cursor_install_skill() {
    log_error "[Cursor CLI] Installation aborted. Cursor CLI does not support loading modular markdown skillsets from a custom directory."
    log_info "[Cursor CLI] Recommendation: Custom prompts are managed inside the Cursor IDE application settings under 'Rules for AI'."
    return 1
}

cursor_remove_skill() {
    log_error "[Cursor CLI] Uninstallation aborted. No custom skill directory exists for Cursor CLI."
    return 1
}

cursor_reload_cli() {
    return 0
}

cursor_doctor() {
    log_warn "[Cursor CLI] Cursor CLI is detected but does not support modular custom skill directories natively."
    return 0
}

cursor_validate() {
    return 1
}
