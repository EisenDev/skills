# Supported AI Clients

The `ai-cli-mcp-installer` currently supports the following AI CLI tools. 

## Antigravity CLI (AGY)
- **Detection Path**: `~/.gemini/antigravity-cli/`
- **Config File**: `~/.gemini/antigravity-cli/mcp.json`
- **Details**: Antigravity is a primary supported target. If the configuration directory exists, the script ensures `mcp.json` is updated.

## Claude Code CLI
- **Detection Path**: `~/.claude/` or `~/.config/claude/`
- **Config File**: `~/.claude/claude.json` or `~/.config/claude/mcp.json`
- **Details**: Claude Code can store its MCP config in multiple locations depending on the platform and installation path. The script attempts to detect and use the appropriate configuration file.

## OpenAI Codex CLI
- **Detection Path**: `~/.config/codex/`
- **Config File**: `~/.config/codex/mcp.json`
- **Details**: Support for Codex CLI handles standard MCP JSON server configurations.

## Adding Support for More Clients
If you wish to add support for another CLI:
1. Identify the configuration path where the CLI reads its `mcpServers`.
2. Add the path detection to the `detect_and_install` function in `setup_ai_mcp.sh`.
3. Call `merge_json "$NEW_CLIENT_CONFIG_FILE"` within that block.
