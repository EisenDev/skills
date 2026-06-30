# Code Review Workflow

## Purpose
To verify the quality, security, performance, and correctness of code changes submitted by peers before merging.

## When to Use
- When reviewing a Pull Request (PR) or merge request.

## Required Prerequisite Skills
- `architecture-thinking` (to evaluate code design)
- `security-first` (to inspect for security flaws)
- `quality-gates` (to check formatting, linting, and coverage)

## Expected Inputs
- A Pull Request URL or git diff payload.
- Project engineering standards (API, Database, Coding Style).

## Execution Workflow
1. **Understand Context**: Read the PR description and associated ticket. Understand *what* changes are being made and *why*.
2. **Check Automated Gates**: Confirm that CI builds, linters, and unit tests have passed. If not, halt the review and request fixes.
3. **Review Architecture**: Check if class patterns, module boundaries, and interfaces conform to `architecture-thinking` principles.
4. **Evaluate Standards**: Compare the diff against:
   - `coding-style` (naming, file sizes, structure).
   - `api-standards` / `database-standards` (if API or database changes exist).
5. **Perform Security Inspection**: Apply `security-first` guidelines to check for sql injection, missing authorization, or hardcoded secrets.
6. **Suggest Improvements**: Write clear, actionable comments on lines containing issues. Suggest concrete code alternatives.
7. **Submit Verdict**: Approve the changes, request changes, or comment.

## Expected Outputs
- A structured code review containing line-by-line feedback.
- A final status (Approved, Request Changes, or Comment).

## Completion Checklist
- [ ] PR description and task requirements are fully understood.
- [ ] Automated quality gates are checked and verified as passing.
- [ ] Code matches codebase structural, database, and API standards.
- [ ] Security risks have been evaluated and mitigated.
- [ ] Feedback is constructive, objective, and provides clear action steps.
