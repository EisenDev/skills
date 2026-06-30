---
name: quality-gates
version: 1.0.0
category: core
author: Zeraynce Engineering
dependencies: []
description: Standardized quality gates module.
---

# Quality Gates

## Overview
This skill governs the definitions, thresholds, and automated checks that code must pass before it is allowed to merge, release, or deploy. It enforces code quality and structural integrity.

## Purpose
To block substandard, unformatted, untested, or broken code from entering the main codebase branch.

## When to Use
- During the continuous integration (CI) pipeline setup.
- Before submitting a Pull Request for review.
- Before executing a release workflow.

## When NOT to Use
- Do NOT use this skill to write unit tests or mock database interfaces (use `testing-first`).
- Do NOT use this skill for defining coding style guidelines (use `coding-style`).

## Principles
1. **Automation**: Every quality gate check must be executable without human intervention.
2. **Zero Tolerance**: If any quality gate fails, the build is blocked.
3. **Actionable Feedback**: Gate failures must clearly state why they failed and how to remediate the issue.

## Workflow
1. **Configure Linting & Formatting**: Ensure tools like ESLint, Ruff, or Prettier run automatically.
2. **Define Coverage Thresholds**: Set minimum test coverage requirements (e.g., 80% line coverage).
3. **Static Analysis**: Integrate security scanners (e.g., Bandit, SonarQube) to check for anti-patterns.
4. **Pre-commit Checks**: Run local hooks before code is committed.
5. **CI Integration**: Require all checks to pass on pull requests before merge permissions are unlocked.

## Rules
- You MUST NOT bypass quality gates (e.g., using `--no-verify` in Git) without documented lead approval.
- Code style formatting MUST be automated; manual style corrections in PR reviews should be avoided.
- Test coverage MUST not decrease relative to the baseline of the target branch.

## Best Practices
- Run fast checks (linters, quick unit tests) first, followed by slower checks (integration tests, security scanning).
- Store quality gate configurations as code within the repository.
- Ensure local check outputs match CI environment outputs exactly.

## Common Mistakes
- Setting quality gates so strict that they block critical hotfixes during emergencies.
- Allowing warnings to accumulate, creating "warning fatigue" where developers ignore gate outputs.
- Running quality checks only on release branches rather than on every PR.

## Anti-patterns
- **The Threshold Trick**: Writing meaningless tests simply to inflate coverage numbers to pass the quality gate.
- **Silent Gates**: Quality gates that report failures but do not block the build or merge.

## Examples
*Example: CI Gate configuration for a Node.js project.*
- Step 1: `npm run lint` (ESLint) - fails on formatting or style issues.
- Step 2: `npm run test:cov` (Jest) - fails if overall coverage is under 85%.
- Step 3: `npm run audit` (npm audit) - fails if high/critical CVEs exist in dependencies.
- Result: Merging to `main` is disabled if any step fails.

## Completion Checklist
- [ ] Linting and formatting rules are configured and automated.
- [ ] Test coverage threshold is defined and enforced in CI.
- [ ] Static analysis tools and dependency checkers are active.
- [ ] Gate rules are defined as code and run on every commit/PR.
- [ ] Bypassing quality gates is restricted via repository permissions.
