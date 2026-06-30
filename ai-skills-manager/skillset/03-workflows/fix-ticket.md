---
name: fix-ticket
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["systematic-debugging", "root-cause-analysis", "testing-first", "architecture-thinking", "verification-before-completion"]
description: Standardized Fix Ticket module.
metadata:
  short-description: "Standardized Fix Ticket module."
---

# Fix Ticket Workflow

## Overview
This workflow governs the implementation and code modification phase. It is a completely separate process from ticket creation, authorized only when a verified ClickUp task is assigned.

## Purpose
To execute code modifications, run tests, update ticket status, and commit/push changes to resolve a ticket.

## When to Use
- Only when implementing a solution for a verified ticket (e.g., `/fix FIX-101`).

## Required Prerequisite Skills
- `systematic-debugging`
- `root-cause-analysis`
- `testing-first`
- `architecture-thinking`
- `verification-before-completion`

## Execution Workflow

### 1. Retrieve Task Details from ClickUp
Use the `clickup_get_task` tool to load task parameters for the specified task ID:
- Pass `task_id`.
- Use the `include` parameter to fetch `["description", "custom_fields"]` to obtain the full ticket details and acceptance criteria.
- Use `expand_statuses=true` if you need to discover the valid statuses configured for this list.

### 2. Analyze Ticket Specifications
Read the retrieved task description and custom fields to extract:
- Acceptance Criteria.
- Proposed solution design.
- If an investigation report is attached, download and review it.

### 3. Move Task to "In Development"
Use the `clickup_update_task` tool to transition the task's `status` to `In Development` (or the equivalent list-specific active status).

### 4. Setup Git Branch
1. Create or check out a branch matching the task ID and Conventional Commit naming standards (e.g., `feature/FIX-101-reports` or `bugfix/FIX-101-timeout`).
2. Sync the project codebase locally.

### 5. Load Skills & Core Reasoning
Load and utilize the core reasoning and engineering standards:
- `systematic-debugging` to locate codebase modules.
- `root-cause-analysis` to address the bug core (if bug).
- `testing-first` to create automated tests aligned with acceptance criteria.
- `architecture-thinking` to plan changes.

### 6. Implement Solution
1. Apply codebase modifications to resolve the problem.
2. Maintain documentation integrity by preserving all existing comments and docstrings.
3. Write automated unit and integration tests covering the acceptance criteria.

### 7. Run Verification Tests
1. Run all unit and integration tests locally.
2. Perform manual validation to verify acceptance criteria are satisfied and no regressions are introduced.

### 8. Post Progress Update
Use the `clickup_create_comment` tool to post a summary of files modified, changes made, and test results:
- Set `entity_id` to the task ID.
- Populate `comment_text` with the formatted markdown summary.

### 9. Commit & Push
1. Commit changes using Conventional Commits format, referencing the task ID in the message (e.g., `feat(reports): [FIX-101] integrate real database data`).
2. Push the branch to remote origin.
3. Open a Pull Request.

### 10. Complete Task Status
1. Transition the ClickUp task status to `Code Review` (or `Done`) using `clickup_update_task`.
2. Post a final comment on ClickUp using `clickup_create_comment` with the Pull Request link, summary of deliverables, and final verification status.

## Completion Checklist
- [ ] ClickUp task retrieved and specifications analyzed.
- [ ] ClickUp task status moved to "In Development" at start.
- [ ] Local branch created/checked out with task ID.
- [ ] Code modifications implemented following architectural guidelines.
- [ ] Automated tests implemented and successfully passed.
- [ ] Progress comment posted to ClickUp task.
- [ ] Changes committed and pushed to remote origin.
- [ ] ClickUp task status updated to "Code Review" or "Done".
- [ ] Final comment containing PR link and test verification posted to ClickUp.
