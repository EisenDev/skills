# AI CLI MCP Installer

Automatically detect installed AI CLI agents and configure the official **ClickUp MCP Server** for them.

## Overview

The `ai-cli-mcp-installer` is a production-ready bash script designed to simplify the installation of the ClickUp Model Context Protocol (MCP) server across multiple AI agents. Rather than manually configuring each of your CLI assistants, this tool automatically finds them and injects the proper SSE MCP configuration safely.

## Features

- **Auto-Detection**: Automatically finds installed AI CLIs.
- **Idempotent**: Safe to run multiple times. Will not duplicate configurations.
- **Safe JSON Merging**: Uses `jq` to safely merge JSON. Includes a Python fallback if `jq` is not available.
- **Automated Backups**: Creates timestamped backups before modifying any configurations.
- **No Dependencies**: Written in pure Bash and standard tools.
- **Uninstaller**: Includes a dedicated script to safely remove the ClickUp MCP without touching other configurations.

## Supported AI Clients

The installer automatically detects the following AI clients:

- **Antigravity CLI (AGY)**
- **Claude Code CLI**
- **OpenAI Codex CLI**

## Installation

You can clone this repository to use the scripts directly:

```bash
git clone https://github.com/your-org/ai-cli-mcp-installer.git
cd ai-cli-mcp-installer
chmod +x setup_ai_mcp.sh uninstall_ai_mcp.sh
```

## Usage

Run the setup script:

```bash
./setup_ai_mcp.sh
```

### Options

- `--help` : Show help message
- `--dry-run` : Run without modifying any files (preview mode)
- `--force` : Force installation even if it's already configured
- `--verbose` : Enable detailed debug logging

Example:

```bash
./setup_ai_mcp.sh --dry-run --verbose
```

### Uninstallation

To remove the ClickUp MCP server configuration:

```bash
./uninstall_ai_mcp.sh
```

## How Detection Works

The script looks for standard configuration directories in your home folder. For example:
- `~/.gemini/antigravity-cli/mcp.json`
- `~/.config/claude/mcp.json` or `~/.claude/claude.json`
- `~/.config/codex/mcp.json`

When a directory is found, the script ensures that the `mcp.json` file is correctly formatted and merges the ClickUp MCP server configuration into it. If the configuration file does not exist but the client directory does, it initializes a new JSON file for you.

## Example Outputs

```text
ℹ Detecting AI CLIs...
✓ Antigravity CLI found
ℹ Installing ClickUp MCP for Antigravity CLI...
✓ Claude Code found
ℹ Installing ClickUp MCP for Claude Code...
✗ Codex CLI not installed
✓ Installation completed
```

## FAQ

**Q: Will this script overwrite my other MCP servers?**  
A: No, the script uses `jq` (or Python) to perform a safe dictionary merge, which leaves all other configured servers completely untouched.

**Q: What if I don't have `jq` installed?**  
A: The script includes a safe Python 3 fallback to perform the JSON merge. If neither are available and the file contains data, the script safely exits without corrupting your config.

**Q: Are my configurations backed up?**  
A: Yes! A timestamped backup file (e.g., `mcp.json.backup-YYYYMMDD-HHMMSS.json`) is created before any changes are made.

**Q: Can I run this on macOS or Windows?**  
A: This script was specifically designed and tested for Linux. It may work on macOS or WSL, but results are not guaranteed.

## Troubleshooting

Please see [docs/troubleshooting.md](docs/troubleshooting.md) for detailed help and debugging tips.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
