---
name: dependency-management
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized dependency management module.
metadata:
  short-description: "Standardized Dependency Management module."
---

# Dependency Management Standards

## Overview
This document defines guidelines for adding, pinning, scanning, updating, and auditing external packages, frameworks, and libraries.

## Purpose
To maintain application security, ensure reproducible builds, and prevent software supply chain vulnerabilities.

## When to Use
- When introducing a new library or dependency to the codebase.
- When updating packages to address security issues.
- When configuring lockfile rules.

## When NOT to Use
- Do NOT use this document to design database keys (use `database-standards`).
- Do NOT use this document to configure git workflows (use `gitflow`).

## Principles
1. **Minimal Dependencies**: Only introduce dependencies when building the feature internally is impractical or highly complex.
2. **Reproducible Builds**: Pin all dependencies and maintain strict lockfiles.
3. **Continuous Auditing**: Scan dependencies for security vulnerabilities and license violations automatically in CI.
4. **Vetting**: Evaluate package maintenance, download trends, and issue backlogs before importing.

## Workflow
*Note: This is a standard.*

## Rules
- You MUST commit package lockfiles (`package-lock.json`, `poetry.lock`, `go.sum`) to version control.
- You MUST pin package versions to exact releases or secure semantic version boundaries (no wildcards or loose ranges).
- Adding a dependency MUST be approved by a tech lead after reviewing alternative packages and sizing overheads.
- Packages with licenses that restrict commercial use (e.g., GPL, AGPL) MUST NOT be imported without explicit legal clearance.

## Best Practices
- Run automated vulnerability scanners (e.g., `npm audit`, `snyk`, `pip-audit`) during CI runs.
- Keep dependencies updated using automated systems (e.g., Dependabot).
- Place build-only utilities in developmental dependencies (`devDependencies`), keeping production runtimes clean.

## Common Mistakes
- Importing large utility libraries (like lodash) for a single simple function.
- Deleting lockfiles to resolve package conflict messages.
- Running unverified install commands directly from the internet inside production containers.

## Anti-patterns
- **Dependency Bloat**: Importing packages that pull in hundreds of nested sub-dependencies, inflating package size.
- **The Abandoned Library**: Relying on unmaintained packages whose last commit was several years ago.

## Examples
*Example: Node dependency installation parameters.*
```bash
# Good: Pinning dependency explicitly and saving as dev dependency
npm install --save-dev typescript@5.3.3

# Good: Standard production dependency install preserving lockfile
npm ci
```

## Completion Checklist
- [ ] New packages are vetted for health, footprint, and licensing.
- [ ] Dependencies are pinned to exact versions in project manifest.
- [ ] Lockfiles are updated and committed to version control.
- [ ] Vulnerability audit passes with zero critical or high-severity issues.
- [ ] Non-production tools are segregated into development dependencies.
