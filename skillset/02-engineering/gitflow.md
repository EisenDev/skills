# Gitflow Standards

## Overview
This document defines git branching conventions, commit message structures, code merging rules, and pull request requirements.

## Purpose
To maintain clean repository histories, prevent branch chaos, and ensure seamless team collaboration.

## When to Use
- When creating feature, hotfix, or release branches.
- When drafting commit messages.
- When creating, reviewing, and merging Pull Requests.

## When NOT to Use
- Do NOT use this document to define linter settings or code formatting rules (use `quality-gates`).
- Do NOT use this document to design database schemas (use `database-standards`).

## Principles
1. **Protected Branch Integrity**: The main development branches (`main`, `develop`) must never be modified directly; all changes must pass through pull requests.
2. **Atomic Commits**: Commits must represent a single logical change with a passing test suite.
3. **Descriptive History**: Commit logs and branch names must provide context on the change's purpose.
4. **Rebase/Clean Merges**: Avoid messy, circular merge graphs by utilizing structured merge methods.

## Workflow
*Note: This is a standard. See workflow documents for feature creation execution steps.*

## Rules
- Branch names MUST follow standard prefixes: `feature/`, `bugfix/`, `hotfix/`, `chore/` followed by issue identifier and description (e.g., `feature/PROJ-101-user-login`).
- Commit messages MUST adhere to the Conventional Commits specification (e.g., `feat(auth): add login validation parameters`).
- Pull requests MUST require at least one peer approval and successful CI validation before merging.
- Merging to target branches MUST use squash commits (or fast-forward merges) to keep history linear.

## Best Practices
- Rebase your branch against the target branch frequently to resolve conflicts early.
- Keep pull requests small (under 400 lines of changes) to enable thorough code reviews.
- Link relevant issues (e.g., `Closes #123`) in the PR description.

## Common Mistakes
- Committing large binary files or IDE configurations (`.vscode/`, `.idea/`) to source control.
- Submitting pull requests with generic titles like "fixed bug" or "refactored stuff."
- Working on multiple unrelated tasks in a single branch.

## Anti-patterns
- **The Long-Lived Branch**: Keeping a feature branch unmerged for weeks, causing severe conflicts.
- **Force Push to Main**: Modifying shared branch histories with `git push --force`.

## Examples
*Example: Conventional commit message.*
```
feat(payment): integrate stripe credit card processor

- Implement credit card input verification
- Connect payment controller to Stripe SDK
- Handle card declining error codes

Closes PROJ-202
```

## Completion Checklist
- [ ] Branch is named correctly with appropriate prefix and issue ID.
- [ ] Commit messages follow the Conventional Commits spec.
- [ ] Branch has been rebased against target and has no merge conflicts.
- [ ] Pull request description links to tasks and outlines changes.
- [ ] Merge uses the squash-and-merge strategy to preserve linear history.
