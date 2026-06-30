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

Clone this repository:

```bash
git clone https://github.com/your-org/ai-cli-mcp-installer.git
cd ai-cli-mcp-installer
```

---

## Usage — Linux / macOS (Bash)

```bash
chmod +x setup_ai_mcp.sh uninstall_ai_mcp.sh

# Install ClickUp MCP for all detected CLIs
./setup_ai_mcp.sh

# Preview without making changes
./setup_ai_mcp.sh --dry-run --verbose

# Force reinstall even if already configured
./setup_ai_mcp.sh --force

# Run diagnostics
./setup_ai_mcp.sh --diagnose

# Uninstall
./uninstall_ai_mcp.sh
```

---

## Usage — Windows

Two sets of Windows-native scripts are provided.

### Prerequisites (Windows)

1. **Python 3** — Install from [python.org](https://www.python.org/downloads/). Ensure it is on `PATH`.
2. **Node.js + npx** — Required for the `mcp-remote` bridge. Install from [nodejs.org](https://nodejs.org/).

---

### Option A — Windows PowerShell

Open **PowerShell** (or Windows Terminal) and run:

```powershell
# Allow local scripts (one-time, if needed)
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# Navigate to the project folder
cd C:\Users\<you>\path\to\ai-cli-mcp-installer

# Install ClickUp MCP for all detected CLIs
.\setup_ai_mcp.ps1

# Preview without making changes
.\setup_ai_mcp.ps1 -DryRun -Verbose

# Force reinstall even if already configured
.\setup_ai_mcp.ps1 -Force

# Run diagnostics
.\setup_ai_mcp.ps1 -Diagnose

# Uninstall
.\uninstall_ai_mcp.ps1

# Uninstall preview
.\uninstall_ai_mcp.ps1 -DryRun
```

---

### Option B — Git Bash (MINGW64 / MSYS2)

Open **Git Bash** and run:

```bash
# Make executable (first time only)
chmod +x setup_ai_mcp_gitbash.sh uninstall_ai_mcp_gitbash.sh

# Install ClickUp MCP for all detected CLIs
./setup_ai_mcp_gitbash.sh

# Preview without making changes
./setup_ai_mcp_gitbash.sh --dry-run --verbose

# Force reinstall even if already configured
./setup_ai_mcp_gitbash.sh --force

# Run diagnostics
./setup_ai_mcp_gitbash.sh --diagnose

# Uninstall
./uninstall_ai_mcp_gitbash.sh

# Uninstall preview
./uninstall_ai_mcp_gitbash.sh --dry-run
```

> **Why not use `setup_ai_mcp.sh` directly on Git Bash?**
> Git Bash (MINGW64) expands `$HOME` as a POSIX path (`/c/Users/...`), but Python on
> Windows requires Windows-style paths (`C:\Users\...`). The `*_gitbash.sh` scripts use
> `cygpath` (or a `sed` fallback) to convert paths before any Python call, fixing the
> `[Errno 2] No such file or directory` error when reading or writing config JSON files.

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

**Q: Can I run this on macOS?**  
A: The `.sh` scripts should work on macOS. Results are not guaranteed but the logic is portable bash.

**Q: Can I run this on Windows?**  
A: Yes — use `setup_ai_mcp.ps1` (PowerShell) or `setup_ai_mcp_gitbash.sh` (Git Bash). Do **not** run `setup_ai_mcp.sh` directly in Git Bash; it will fail with a Python path error.

## Troubleshooting

Please see [docs/troubleshooting.md](docs/troubleshooting.md) for detailed help.

### Windows: `[Errno 2] No such file or directory` (Git Bash)
**Cause**: Running `setup_ai_mcp.sh` directly in Git Bash. Python cannot open MINGW64 POSIX paths.
**Fix**: Use `./setup_ai_mcp_gitbash.sh` instead.

### Windows: `running scripts is disabled on this system` (PowerShell)
**Cause**: PowerShell execution policy is blocking the script.
**Fix**:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Windows: `npx` not found
**Cause**: Node.js is not installed or not on PATH.
**Fix**: Install from [nodejs.org](https://nodejs.org/) and restart the terminal.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
