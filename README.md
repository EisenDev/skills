# AI Platform

The **AI Platform** is a modular engineering infrastructure for deploying standardized skills, workflows, agent personas, and MCP integrations across multiple AI command-line interfaces (AGY, Claude Code, Codex, etc.).

It is the single source of truth for how AI agents in this organization reason, behave, create tickets, fix bugs, and interact with project management tools.

---

## Repository Structure

```
ai-platform/
├── ai-skills-manager/       # Skill package manager — install, update, validate skills
├── ai-cli-mcp-installer/    # MCP server installer — configure ClickUp MCP across CLIs
├── skillset/                # Workspace-level active skillset (symlinked by AGY)
└── .clickup.json            # Project-level ClickUp routing configuration
```

---

## Modules

### 🧠 [`ai-skills-manager`](./ai-skills-manager/README.md)
The core skill package manager. Manages a library of modular AI skills organized into four categories: **Core Reasoning**, **Engineering Standards**, **Workflows**, and **Agent Personas**. Skills are installed as symlinks into the target CLI's skill directory and validated against a standardized markdown schema.

**Key scripts:**
| Script | Description |
| :--- | :--- |
| `install-skills.sh` | Fresh install of all skills to a target CLI |
| `update-skills.sh` | Sync new, changed, and removed skills |
| `uninstall-skills.sh` | Remove all installed skills from a CLI |
| `validate-skills.sh` | Validate all skill markdown files against the schema |
| `list-skills.sh` | Display skills grouped by category |
| `doctor.sh` | Run a health check on installed skills and symlinks |

**Quick start:**
```bash
cd ai-skills-manager
chmod +x *.sh
./install-skills.sh --agy         # Install to Antigravity CLI
./update-skills.sh --agy          # Sync changes
./validate-skills.sh              # Validate all skill files
```

> **Windows users:** This requires Bash. Use **Git Bash**, **WSL**, or run via `wsl ./update-skills.sh --agy` from PowerShell.

---

### 🔌 [`ai-cli-mcp-installer`](./ai-cli-mcp-installer/README.md)
A Bash utility that auto-detects installed AI CLI agents and injects the **ClickUp MCP server** configuration into each one. Safe to run multiple times — creates timestamped backups and never overwrites unrelated configurations.

**Supported CLIs:** Antigravity CLI (AGY), Claude Code, OpenAI Codex

**Quick start:**
```bash
cd ai-cli-mcp-installer
chmod +x setup_ai_mcp.sh uninstall_ai_mcp.sh
./setup_ai_mcp.sh                 # Install ClickUp MCP for all detected CLIs
./setup_ai_mcp.sh --dry-run       # Preview without modifying files
./uninstall_ai_mcp.sh             # Remove ClickUp MCP configuration
```

---

### 📁 `skillset/`
The live, workspace-level copy of all skill markdown files. When skills are installed via `ai-skills-manager` in symlink mode, the AGY CLI reads directly from this directory. These files are the canonical source for all skill content.

```
skillset/
├── 01-core/          # Core reasoning modules
├── 02-engineering/   # Engineering standards
├── 03-workflows/     # Agentic workflow definitions
└── 04-agents/        # Agent persona definitions
```

---

### ⚙️ `.clickup.json`
Project-level ClickUp routing configuration. AGY reads this file during the `/create-ticket` workflow to determine which ClickUp Workspace, Space, and List new tasks should be created in.

```json
{
  "version": "1.0",
  "project": {
    "name": "ai-platform"
  },
  "clickup": {
    "workspace": { "name": "Arjay Escabas's Workspace", "id": "90161675293" },
    "space":     { "name": "Space",                     "id": "90167325641" },
    "folder":    null,
    "list":      { "name": "General Tasks",             "id": "901615603605" }
  }
}
```

---

## Skillset Catalog

### 01 · Core Reasoning
Foundational reasoning modules loaded by workflows automatically.

| Skill | Description |
| :--- | :--- |
| `architecture-thinking` | Evaluate and design system architecture before implementing |
| `documentation-first` | Write docs and specs before writing code |
| `quality-gates` | Define and enforce quality checkpoints |
| `root-cause-analysis` | Identify the systemic root cause of failures |
| `security-first` | Apply security principles throughout development |
| `systematic-debugging` | Hypothesis-driven, scientific bug isolation |
| `testing-first` | Write tests before implementation |
| `verification-before-completion` | Verify acceptance criteria before closing work |

---

### 02 · Engineering Standards
Domain-specific coding and architectural standards.

| Skill | Description |
| :--- | :--- |
| `accessibility` | WCAG-compliant accessibility guidelines |
| `api-standards` | REST API design conventions |
| `backend-standards` | Server-side architecture and data handling rules |
| `coding-style` | Universal formatting and naming conventions |
| `database-standards` | Schema design and query optimization rules |
| `dependency-management` | Library versioning and upgrade policies |
| `docker-standards` | Container image, compose, and deployment rules |
| `documentation-standards` | Inline docs, changelogs, and API doc standards |
| `error-handling` | Structured exception and error propagation patterns |
| `frontend-standards` | Component architecture and state management rules |
| `gitflow` | Branching, commit, and PR workflow standards |
| `logging` | Structured logging formats and levels |
| `performance` | Profiling, caching, and optimization guidelines |
| `ui-standards` | Visual consistency, design tokens, and UX rules |

---

### 03 · Workflows
Agentic step-by-step workflows that drive how AGY completes engineering tasks.

| Workflow | Trigger | Description |
| :--- | :--- | :--- |
| `create-ticket` | `/create-ticket <request>` | Investigate a request and publish a structured ClickUp task with a unique incremented ID (e.g. `BUG-001`, `DEBT-002`). Attaches the investigation report to the task. |
| `fix-ticket` | `/fix-ticket <task-id>` | Retrieve a ClickUp task, implement the solution, run tests, post progress comments, commit, and update the task status. |
| `create-feature` | `/create-feature <spec>` | Full feature development from design to deployment-ready PR. |
| `code-review` | `/code-review <pr>` | Review a pull request for quality, security, and architectural correctness. |
| `api-design` | `/api-design <spec>` | Design and document a REST API before implementation. |
| `database-design` | `/database-design <spec>` | Design schema migrations and data models. |
| `deployment` | `/deployment <target>` | Prepare and execute a production deployment. |
| `release` | `/release <version>` | Cut a release, update changelogs, and tag the version. |
| `security-review` | `/security-review <target>` | Perform a security audit on a codebase or PR. |
| `investigate-production-issue` | `/investigate <issue>` | Systematically diagnose a live production failure. |

---

### 04 · Agent Personas
Role-specific personas that constrain how AGY reasons and what it focuses on.

| Persona | Role |
| :--- | :--- |
| `backend-engineer` | Server-side development, APIs, and databases |
| `frontend-engineer` | UI components, state management, and browser rendering |
| `fullstack-engineer` | End-to-end features spanning database to UI |
| `devops-engineer` | Infrastructure, CI/CD, containers, and deployments |
| `qa-engineer` | Test strategy, automation, and quality assurance |
| `security-engineer` | Threat modeling, vulnerability analysis, and secure coding |
| `software-architect` | System design, patterns, and technical decision-making |
| `technical-writer` | Documentation, runbooks, and API references |
| `ui-ux-designer` | Design systems, accessibility, and user experience |

---

## ClickUp Integration

When `create-ticket` is invoked, AGY will:

1. **Query existing tasks** in the configured ClickUp list to find the highest ticket number for that prefix (e.g., `BUG-005`).
2. **Increment the ID** and generate the next unique ticket (e.g., `BUG-006`), starting at `001` if none exist.
3. **Create the task** in ClickUp with the ticket title, a markdown description containing the Summary, Problem, and Acceptance Criteria.
4. **Attach the investigation report** markdown file directly to the ClickUp task.
5. **Return** the Task ID, Task URL, and confirmation of the attached report.

When `fix-ticket` is invoked, AGY will:

1. **Retrieve the task** from ClickUp including full description, custom fields, and available statuses.
2. **Move the status** to `In Development`.
3. **Implement the solution**, run tests, and post a progress comment to the task.
4. **Commit & push**, then move the task status to `Code Review` or `Done` and post the PR link as a final comment.

---

## FAQ

**Q: Does this work on Windows?**  
The shell scripts require Bash. Use **Git Bash**, **WSL**, or run via `wsl ./update-skills.sh --agy` from PowerShell/CMD.

**Q: What CLIs are supported for skills?**  
Currently only **Antigravity CLI (AGY)** is fully supported with symlink-based skill installation. Other CLIs (Claude Code, Codex, Gemini, Cursor) are detected but not yet supported.

**Q: How does the ClickUp MCP connect?**  
The `ai-cli-mcp-installer` injects an SSE-based MCP server entry into each CLI's `mcp.json`. AGY then calls ClickUp tools (`clickup_create_task`, `clickup_filter_tasks`, `clickup_attach_task_file`, etc.) directly via that MCP connection.

**Q: Do I need a `.clickup.json` in every project?**  
Yes. Each project that uses the `create-ticket` workflow needs its own `.clickup.json` at the root to tell AGY which ClickUp workspace, space, and list to publish tasks to.

---

## License

Internal use only — Zeraynce Engineering.
