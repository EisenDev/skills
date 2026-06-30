---
name: create-ticket
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["systematic-debugging", "testing-first", "documentation-first"]
description: Standardized create ticket module.
---

# Create Ticket Workflow

## Purpose
To structure, document, and formalize a task, feature request, or bug report into an actionable backlog item.

## When to Use
- When a new feature request is defined by product.
- When an engineering task is identified during development.
- When a software bug is discovered and requires prioritization.

## Required Prerequisite Skills
- `systematic-debugging` (for bug reports)
- `testing-first` (for defining test expectations)
- `documentation-first` (for clarifying functional specifications)

## Expected Inputs
- A raw request, bug description, or business requirement description.
- Observed behavior or environment conditions (if reporting a bug).

## Execution Workflow
1. **Analyze Input**: Read through the request. If it is a bug, invoke the `systematic-debugging` principles to identify the target scope and reproduction steps.
2. **Draft Technical Specification**: Write a brief technical path. Use `documentation-first` to outline the system contract changes (API changes, configuration flags).
3. **Define Acceptance Criteria**: Use `testing-first` concepts to list explicit test scenarios that must pass for this ticket to be considered complete.
4. **Draft the Ticket**: Construct the ticket description using a clean markdown format:
   - **Description**: What needs to be built and why.
   - **Technical Approach**: Suggested architecture or modified files.
   - **Acceptance Criteria**: List of test expectations.
   - **Reproduction Steps**: (If bug) Inputs and steps to trigger the bug.
5. **Review**: Ensure no internal implementations or project-specific secrets are included.

## Expected Outputs
- A complete, structured Markdown ticket description ready to be copied into JIRA, GitHub Issues, or a task manager.

## Completion Checklist
- [ ] The core problem or feature requirement is clearly stated.
- [ ] Prerequisite skills (`systematic-debugging`, `testing-first`, `documentation-first`) have been executed to gather context.
- [ ] Input parameters and expected outputs are specified.
- [ ] Acceptance criteria contain explicit, testable outcomes.
- [ ] Verification steps are detailed.
