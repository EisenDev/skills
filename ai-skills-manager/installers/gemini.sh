#!/usr/bin/env bash

# gemini.sh - Gemini CLI Adapter Module (Graceful Unsupported Target)

gemini_detect_cli() {
    if command -v gemini &>/dev/null || [ -d "$HOME/.gemini-cli" ] || [ "${MOCK_GEMINI_INSTALLED}" = "1" ]; then
        return 0
    fi
    return 1
}

gemini_get_skill_directory() {
    echo ""
}

gemini_install_skill() {
    log_error "[Gemini CLI] Installation aborted. Gemini CLI does not support loading custom markdown-based skills dynamically from a dedicated directory."
    log_info "[Gemini CLI] Recommendation: Custom prompts should be passed as text prompt input templates or referenced during run commands."
    return 1
}

gemini_remove_skill() {
    log_error "[Gemini CLI] Uninstallation aborted. No custom skill directory exists for Gemini CLI."
    return 1
}

gemini_reload_cli() {
    return 0
}

gemini_doctor() {
    log_warn "[Gemini CLI] Gemini CLI is detected but does not support modular custom skill directories natively."
    return 0
}

gemini_validate() {
    return 1
}
