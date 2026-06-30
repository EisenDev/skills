---
name: create-ticket
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["documentation-first", "testing-first", "quality-gates", "systematic-debugging"]
description: Standardized Create Ticket module.
---

# Create Ticket Workflow

## Purpose

Perform a structured investigation of a requested feature, enhancement, refactor, or bug, then create a complete engineering ticket and automatically publish it to the configured project management system (ClickUp) using the project's AGY configuration.

This workflow is **investigation-only**. It must never modify source code.

## When to Use

Use this workflow whenever:

* A new feature is requested.
* A software bug is discovered.
* A refactor is needed.
* Technical debt is identified.
* Existing functionality requires enhancement.
* Documentation reveals missing implementation.
* Product owners request new capabilities.

## Required Prerequisite Skills

Before creating any ticket, AGY must invoke the following skills when applicable:

* `documentation-first` (Required)
* `testing-first` (Required)
* `systematic-debugging` (Conditional for bugs)
* `architecture-review` (Conditional for large changes)
* `security-review` (Conditional for security issues)
* `dependency-analysis` (Conditional for dependency updates)

## Execution Workflow

### 1. Project Configuration
Before performing any work, AGY must locate the project's configuration in `agy.yaml` or `.clickup.json`. The configuration determines Project Name, ClickUp Workspace, Space, Folder (optional), and List.
If no project configuration exists, continue generating the investigation report, skip ClickUp integration, and inform the user that no project destination is configured.

### 2. Investigation Phase
Before writing a ticket, AGY must investigate the existing codebase:
* **Existing Implementation**: Does similar functionality already exist? Which modules already solve part of the problem? Is the feature partially implemented? Is there existing technical debt?
* **Root Cause (Bug)**: If this is a bug, determine root cause, reproduction path, impact, severity, and affected modules.
* **Technical Scope**: Identify controllers, services, models, components, APIs, routes, database tables, configuration, tests, and documentation that will likely require modification.
* **Architecture Assessment**: Determine whether implementation follows existing architecture, whether new modules should be introduced, whether existing services should be reused, or whether refactoring is preferable.
* **Risks**: Identify possible risks (breaking changes, performance, security, migration, compatibility, database impact).

### 3. Ticket Generation
Generate a ticket conforming to the **Ticket Structure** (see below).

To ensure every ticket has a unique, incremented Ticket ID:
1. **Query Existing Tasks**: If ClickUp is configured, use the `clickup_filter_tasks` tool to retrieve tasks in the configured list. Ensure you set `include_closed: true` to check completed tasks as well.
2. **Scan for Existing Identifiers**: Scan the titles of all retrieved tasks for ticket identifiers matching the pattern `[PREFIX-###]` (e.g., `[BUG-001]`, `[DEBT-002]`, etc.) using the prefix determined for the new ticket (e.g., BUG, FEATURE, ENHANCEMENT, REFACTOR, DEBT, SECURITY, DOCS, TEST).
3. **Determine the Next ID**:
   - Find the highest number used for that prefix in the existing task titles (e.g., if `[BUG-001]` and `[BUG-005]` exist, the highest is `5`).
   - Increment that highest number by 1 (e.g., `5 + 1 = 6`) and format it with leading zeros to three digits (e.g., `006` to produce `BUG-006`).
   - If no tasks with that prefix are found, start at `001` (e.g., `[BUG-001]`).

### 4. ClickUp Integration
If project configuration exists, AGY MUST:
1. **Generate the investigation report** (a markdown file containing detailed findings, root cause analysis, architecture review, file paths, etc.).
2. **Create the ClickUp task** using the `clickup_create_task` tool. Populate the arguments as follows:
   - `name`: Use the generated ticket Title (including the engineering ID, e.g., `[BUG-021] Login Session Expires Prematurely`).
   - `markdown_description`: Provide a brief description of the task, containing the **Summary**, **Problem**, and **Acceptance Criteria** sections of the generated ticket.
   - `priority`: Map the ticket's priority (`Critical` -> `urgent`, `High` -> `high`, `Medium` -> `normal`, `Low` -> `low`).
   - `tags`: Pass the area and labels of the ticket as an array of tags (e.g., `["backend", "database"]`).
3. **Attach the Investigation Report file** to the created ClickUp task using the `clickup_attach_task_file` tool:
   - Read the locally generated investigation report markdown file.
   - Encode the file contents to Base64 (omit any data URL/base64 headers, pass only the raw base64 string).
   - Call `clickup_attach_task_file` with:
     - `task_id`: The ID of the newly created ClickUp task.
     - `file_name`: The filename of the investigation report (e.g., `debt009_reports_hardcoded_data.md`).
     - `file_data`: The Base64-encoded content of the file.
4. **Return metadata**: Return the Task ID, Task URL, Project Name, Workspace, Space, List, and a confirmation that the investigation report has been attached to the ClickUp task.
If configuration is missing, generate only the markdown investigation report and explain why ClickUp integration was skipped.

### 5. Constraints
This workflow MUST NOT modify source code, create commits/branches, open PRs, or execute implementation/refactoring.

## Expected Outputs

- A complete, structured Markdown ticket description uploaded to ClickUp (if configured) or returned as output.
- Task ID and URL (if ClickUp is configured).
- The generated investigation report artifact file attached/uploaded to the ClickUp task (if ClickUp is configured).

## Examples

Below is the required **Ticket Structure** that must be used to generate tickets.

### Ticket Structure Specification

The generated ticket MUST be concise, implementation-ready, and follow a standardized engineering format.
The ticket description MUST NOT resemble an investigation report or documentation article.
The ticket MUST contain the following sections in this exact order.

---

### Ticket ID

Generate a human-readable engineering identifier. Every Ticket ID MUST be unique and incremented based on existing tasks in the ClickUp list (e.g., BUG-001, BUG-002, etc.).

Examples:
- `[BUG-001]`
- `[FEAT-014]`
- `[DEBT-008]`
- `[REFACTOR-003]`
- `[SEC-002]`

The ID is for readability only and does not replace the ClickUp Task ID.

Ticket prefixes: BUG, FEATURE, ENHANCEMENT, REFACTOR, DEBT, SECURITY, DOCS, TEST.

---

### Title

A concise engineering title.

Examples:
- `[DEBT-008] Replace Hardcoded Reports Dashboard With Database Data`
- `[BUG-021] Login Session Expires Prematurely`
- `[FEATURE-011] Add Export CSV Capability`

---

### Summary

A one-paragraph overview describing:
• What needs to change
• Why it matters
• Expected business value

Maximum: 5 sentences.

---

### Problem

Describe:
• Current implementation
• Existing limitation
• Business impact
• Technical impact

Avoid implementation details.

---

### Expected Behavior

Describe how the system should behave after implementation.
This should be written from the user's perspective.

---

### Investigation Findings

Summarize important findings discovered during investigation.
Include:
• Existing implementation
• Existing reusable modules
• Related components
• Root cause (if applicable)

Maximum: 10 bullet points.

---

### Proposed Implementation

Describe the recommended implementation strategy.
Include:
• Backend work
• Frontend work
• Database changes
• API changes
• Architecture considerations

Do NOT write code.

---

### Technical Scope

List the likely files/modules requiring modification.

Example:
- Backend Controllers: `ReportsController.php`
- Services: `ReportService.php`
- Frontend: `Reports.vue`, `ReportTable.vue`
- Database: `reports`, `report_exports`
- Routes: `web.php`
- Documentation: `reports.md`

---

### Acceptance Criteria

Every item MUST be testable.

Example:
- Reports page loads live database records.
- All hardcoded arrays removed.
- Pagination works.
- Search functions correctly.
- Filters return accurate results.
- Existing functionality remains unaffected.
- No regression introduced.

---

### Testing Requirements

Specify required verification:
- Unit Tests
- Integration Tests
- Manual QA
- Regression Testing
- Performance Verification
- Security Validation (if applicable)

---

### Risks

Potential implementation risks.

Examples:
- Database migration risk
- Performance impact
- API compatibility
- Breaking UI changes
- Backward compatibility

---

### Dependencies

List required dependencies.

Examples:
- Database migration
- Environment variables
- Third-party API
- Existing feature dependency
- None

---

### Labels

Generate engineering labels.

Examples: backend, frontend, database, security, api, performance, refactor, technical-debt, bug, feature, documentation, testing.

---

### Area

Determine the primary engineering area.

Examples: Backend, Frontend, Infrastructure, Database, DevOps, Authentication, Security, Reporting, Billing, API, UI/UX.

---

### Priority

Determine one: Critical, High, Medium, Low.

---

### Estimated Complexity

One of: Small, Medium, Large, Epic.

---

### Suggested Assignee

If enough information exists, recommend: Backend Engineer, Frontend Engineer, Full Stack Engineer, DevOps Engineer, QA Engineer, Security Engineer. Otherwise: Unassigned.

---

### Deliverables

List expected outputs.

Examples:
- Updated API endpoint
- Database migration
- New Vue component
- Updated documentation
- Automated tests
- Feature flag
- Configuration changes

---

### Definition of Done

The ticket is complete only when:
- Acceptance criteria pass.
- Required tests pass.
- Documentation updated.
- No regression detected.
- Code review completed.
- Feature behaves as expected.

---

### Investigation Artifact

After creating the ClickUp ticket, AGY should also generate a complete investigation report as a Markdown artifact.
The investigation artifact may contain:
- Root cause analysis
- Architecture review
- Detailed findings
- Code references
- File paths
- Technical reasoning

This artifact is supplementary and MUST NOT replace the ClickUp task description.
The ClickUp task should contain only the concise engineering ticket described above.

## Completion Checklist

- [ ] Project configuration loaded.
- [ ] Existing implementation investigated.
- [ ] Related modules identified.
- [ ] Root cause documented (if bug).
- [ ] Technical scope defined.
- [ ] Risks documented.
- [ ] Acceptance criteria are testable.
- [ ] Testing requirements defined.
- [ ] Documentation updates identified.
- [ ] Ticket uploaded to ClickUp (if configured).
- [ ] Task ID and URL returned.