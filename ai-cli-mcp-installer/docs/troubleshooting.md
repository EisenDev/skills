# Troubleshooting Guide

This guide helps you resolve common issues when using the `ai-cli-mcp-installer`.

## 1. "Invalid JSON in..." Error
**Symptom**: The script prints a warning like `⚠ Invalid JSON in ~/.gemini/antigravity-cli/mcp.json. Backing up and resetting.`

**Cause**: The existing MCP configuration file was either corrupted or contained syntax errors (e.g., missing commas, trailing commas, or missing brackets).

**Solution**:
The script automatically backs up your old file and resets it. If you had other MCP servers configured, you can manually copy them from the backup file into the newly generated file. Run the script again or manually verify using `jq . <file>`.

## 2. "jq is required but not installed" (or Fallback Failures)
**Symptom**: The script complains about `jq` or Python missing and fails to merge.

**Cause**: The installer uses `jq` to safely manipulate JSON. If `jq` isn't found, it falls back to Python 3. If neither are found, it cannot safely modify existing JSON files to avoid corrupting them.

**Solution**:
Install `jq` using your package manager:
- **Ubuntu/Debian**: `sudo apt install jq`
- **Fedora**: `sudo dnf install jq`
- **Arch**: `sudo pacman -S jq`

## 3. "ClickUp MCP already exists"
**Symptom**: The script skips installation and prints `⚠ ClickUp MCP already exists in ... Skipping. Use --force to overwrite.`

**Cause**: You have already run the script, or you manually configured a server named `clickup` previously. The script is idempotent by default.

**Solution**:
If you want to overwrite your existing `clickup` configuration with the latest one, run the script with the `--force` flag:
```bash
./setup_ai_mcp.sh --force
```

## 4. No Supported AI CLIs Found
**Symptom**: The script outputs `⚠ No supported AI CLIs were found. Nothing to install.`

**Cause**: None of the configuration directories for Antigravity CLI, Claude Code, or Codex CLI exist in your home directory.

**Solution**:
1. Make sure you have installed at least one of the supported AI CLIs.
2. Ensure you have run them at least once so their configuration directories are created.
3. If you are using a custom configuration path, you may need to symlink it to the default path or manually modify the `setup_ai_mcp.sh` script to point to your custom directory.

## 5. Cannot Restore Uninstalled Config
**Symptom**: You ran `uninstall_ai_mcp.sh` and want your configuration back.

**Solution**:
Just run `./setup_ai_mcp.sh` again to reinstall it. The uninstaller also creates a backup before removing the configuration, formatted like `.uninstall-backup-YYYYMMDD-HHMMSS.json`.

## Still Having Issues?
Try running the script in verbose mode to see more detailed execution steps:
```bash
./setup_ai_mcp.sh --verbose
```
