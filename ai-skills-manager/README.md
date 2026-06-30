# AI Skills Manager

The single source of truth for managing and installing engineering standards, personas, and workflows as custom modular skills across multiple AI command line interfaces.

---

## Architecture

The AI Skills Manager uses an **Adapter Pattern** architecture to decouple the core framework routines (validation, dependency resolution, linking) from platform-specific custom prompt loading mechanisms.

```mermaid
graph TD
    CLI[User Invocation] --> Exec[Script Executables e.g. install-skills.sh]
    Exec --> Core[Core Engine lib/installer.sh]
    Core --> Val[Validator lib/validator.sh]
    Core --> Manifest[Manifest Parser lib/manifest.sh]
    Core --> Symlink[Symlink Engine lib/symlink.sh]
    Core --> Adapters[Adapter Loader lib/cli_detector.sh]
    Adapters --> AdapterAGY[installers/agy.sh]
    Adapters --> AdapterClaude[installers/claude.sh]
    Adapters --> AdapterCodex[installers/codex.sh]
    Adapters --> AdapterGemini[installers/gemini.sh]
    Adapters --> AdapterCursor[installers/cursor.sh]
```

### Key Modules:
- `lib/common.sh`: Centralizes arg parsing, version checks, and sets dry-run/verbose indicators.
- `lib/logger.sh`: Outputs status templates (`✓ Installed`, `✗ Error`) and displays execution times.
- `lib/filesystem.sh`: Protects filesystem checks and wraps commands for safe dry-runs.
- `lib/manifest.sh`: Interface to query `skill-manifest.yaml` properties via Python.
- `lib/validator.sh`: Scans markdown headers (Title, Summary, Purpose, Triggers, Workflow, Output, Examples, Dependencies) and flags broken links.
- `lib/symlink.sh`: Implements symlinking with copy fallback when symlinks fail.
- `lib/installer.sh`: Resolves dependency topological ordering and drives installation/removal sequence.

---

## Installation

1. Clone or copy the repository files to your environment (e.g. `/home/eisen/projects/ai-platform/ai-skills-manager`).
2. Make scripts executable:
   ```bash
   chmod +x *.sh installers/*.sh
   ```
3. Run the validator tool to check framework integrity:
   ```bash
   ./validate-skills.sh
   ```

---

## Supported CLIs

| CLI Platform | Supported | Skill Directory Location | Install Mode | Notes |
| :--- | :---: | :--- | :--- | :--- |
| **Antigravity CLI (AGY)** | **Yes** | `~/.gemini/config/skills` | Symlink | Installs skills as nested `skills/<skill_id>/SKILL.md` targets. |
| **OpenAI Codex CLI** | **Yes** | `~/.codex/AGENTS.md` | Concat | Appends all skills into a single `AGENTS.md` with `<!-- skill:id -->` delimiters for idempotent updates and removal. |
| **Claude Code** | *No* | N/A | Unsupported | Settings belong in `~/.claude.json`. |
| **Gemini CLI** | *No* | N/A | Unsupported | Custom prompts passed inline or via environment options. |
| **Cursor CLI** | *No* | N/A | Unsupported | Prompts managed via IDE settings ('Rules for AI').  |

---

## Examples

### Linux / macOS (Bash)

```bash
# Install skills to Antigravity CLI (AGY)
./install-skills.sh --agy

# Dry-run simulation
./install-skills.sh --agy --dry-run

# Update and synchronize skills
./update-skills.sh --agy

# Run framework doctor health check
./doctor.sh

# List skills grouped by category
./list-skills.sh
```

---

## Windows

Two Windows-native scripts are provided to replace the Linux `install-skills.sh`.

### Prerequisites (Windows)

1. **Python 3** — Install from [python.org](https://www.python.org/downloads/). Ensure it is on `PATH`.
2. **PyYAML** — Install the YAML parser:
   ```powershell
   pip install pyyaml
   ```

---

### Option A — Windows PowerShell

Open **PowerShell** (or Windows Terminal) and run:

```powershell
# Navigate to the project folder
cd C:\Users\<you>\Downloads\Gravityx2\skills\ai-skills-manager

# Allow local scripts (one-time, if needed)
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# Install skills to AGY
.\install-skills.ps1 -Agy

# Install with verbose output
.\install-skills.ps1 -Agy -Verbose

# Dry-run simulation
.\install-skills.ps1 -Agy -DryRun

# Force overwrite all existing skill files
.\install-skills.ps1 -Agy -Force

# Auto-detect all CLIs and install
.\install-skills.ps1 -All

# View help
.\install-skills.ps1 -Help
```

---

### Option B — Git Bash (MINGW64 / MSYS2)

Open **Git Bash** and run:

```bash
# Navigate to the project folder
cd ~/Downloads/Gravityx2/skills/ai-skills-manager

# Make executable (first time only)
chmod +x install-skills-gitbash.sh

# Install skills to AGY
./install-skills-gitbash.sh --agy

# Dry-run simulation
./install-skills-gitbash.sh --agy --dry-run

# Verbose output
./install-skills-gitbash.sh --agy --verbose

# Force overwrite
./install-skills-gitbash.sh --agy --force

# Auto-detect all CLIs
./install-skills-gitbash.sh --all
```

> **Why not use `install-skills.sh` directly on Git Bash?**
> Git Bash (MINGW64) translates paths like `/c/Users/...` internally, but Python on Windows
> cannot open files using those POSIX-style paths. `install-skills-gitbash.sh` uses `cygpath`
> (or a `sed` fallback) to convert paths to Windows format (`C:\Users\...`) before passing
> them to Python, fixing the `Manifest parsing failed: [Errno 2] No such file or directory` error.

#### Windows Symlink Note

Symlinks on Windows require either:
- **Developer Mode** enabled in Windows Settings → Privacy & Security → For Developers, or
- Running Git Bash / PowerShell **as Administrator**.

If neither is available, both scripts automatically fall back to **file copy** mode with a warning.

---

## Manifest Schema

The single source of truth database is `skill-manifest.yaml`. Each skill entry defines:

```yaml
skills:
  - id: systematic-debugging
    name: "Systematic Debugging"
    version: 1.0.0
    category: core
    description: "Standardized Systematic Debugging module."
    author: "Zeraynce Engineering"
    directory: 01-core
    dependencies: []
    required_by:
      - create-ticket
      - fix-ticket
      - investigate-production-issue
    supported_clis:
      - agy
    install_mode: symlink
```

---

## Dependency System

When a workflow requires prerequisites (e.g. `create-ticket` depends on `systematic-debugging`), the installer uses topological sorting (Kahn's/DFS algorithm) to:
1. Load dependencies from `skill-manifest.yaml`.
2. Sequence installs so dependencies are linked first.
3. Detect circular dependencies and abort execution if cycles are found.

---

## Adding & Updating Skills

### Adding a new skill:
1. Add the markdown file under the matching category subdirectory inside `skillset/` (e.g. `skillset/01-core/new-skill.md`).
2. Add corresponding metadata fields to `skill-manifest.yaml`.
3. Run `./validate-skills.sh` to check formatting and links.
4. Execute `./update-skills.sh` to sync the new file with your target CLIs.

### Updating an existing skill:
1. Edit the markdown file inside the local `skillset/` subdirectory.
2. Increment the version tag in `skill-manifest.yaml`.
3. Run `./update-skills.sh` to push modifications to target directories.

---

## Troubleshooting

### Error: Missing Metadata Fields
**Cause**: The markdown file is missing required headings (such as `## Purpose` or `## Workflow`).
**Fix**: Edit the markdown file and ensure the required headings exist.

### Error: Broken Link Detected
**Cause**: A link using the `file://` scheme or a relative path points to a file that does not exist.
**Fix**: Verify the file path and update the reference in the markdown file.

### Error: Circular Dependency Detected
**Cause**: Skill A depends on Skill B, and Skill B depends on Skill A.
**Fix**: Redesign the skills manifest to eliminate recursive loops.

### Windows: `Manifest parsing failed: [Errno 2] No such file or directory`
**Cause**: Running `install-skills.sh` directly in Git Bash (MINGW64). Git Bash expands
paths like `/c/Users/...`, but Python on Windows cannot open those POSIX-style paths.
**Fix**: Use `install-skills-gitbash.sh` (Git Bash) or `install-skills.ps1` (PowerShell) instead.

### Windows: `running scripts is disabled on this system`
**Cause**: PowerShell execution policy is blocking the script.
**Fix**: Run once in PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Windows: `pyyaml` not found
**Cause**: Python is installed but PyYAML is missing.
**Fix**:
```powershell
pip install pyyaml
```

---

## FAQ

#### Can I install individual skills?
Yes, the framework allows individual CLI targeting via flags, but always sequences installs topologically to ensure all required dependencies are present.

#### Why does Claude Code/Codex/Gemini report "Unsupported"?
These platforms do not natively support modular, dynamic markdown custom prompt folders in their current CLI implementations. The framework detects these capabilities and gracefully fails instead of duplicating files or setting fake overrides.
