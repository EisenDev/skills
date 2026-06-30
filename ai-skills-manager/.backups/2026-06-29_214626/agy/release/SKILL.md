---
name: release
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["quality-gates", "verification-before-completion"]
description: Standardized release module.
---

# Release Workflow

## Purpose
To compile, version, tag, and prepare a stable snapshot of the codebase for deployment.

## When to Use
- When preparing a new version of the software (e.g., v1.1.0) to be sent to production.

## Required Prerequisite Skills
- `quality-gates` (to ensure build verification)
- `verification-before-completion` (to validate release candidates)

## Expected Inputs
- A target branch containing features to release (e.g., `develop`).
- Release version identifier (following Semantic Versioning).

## Execution Workflow
1. **Verify Release Candidate**: Ensure all code in the release candidate has passed the `verification-before-completion` workflow.
2. **Run Quality Gates**: Run the complete suite of security scanners, linters, and integration tests (`quality-gates`).
3. **Prepare Release Branch**: Create a branch named `release/v[Version]` from the development branch.
4. **Increment Version**: Update version identifiers in files (e.g. `package.json`, `Cargo.toml`).
5. **Update Changelog**: Aggregate commit history since the last release into a `CHANGELOG.md` file.
6. **Merge and Tag**: Merge the release branch into `main`. Tag the commit with `v[Version]` (e.g., `git tag -a v1.2.0 -m "Release v1.2.0"`).
7. **Publish Artifacts**: Compile build binaries, publish libraries, or build Docker images.

## Expected Outputs
- A tagged commit on the main branch.
- Updated version files and a completed `CHANGELOG.md`.
- Generated build artifacts (e.g., libraries, Docker images).

## Completion Checklist
- [ ] Quality gates are green for the release commit.
- [ ] Version variables are updated across configuration files.
- [ ] Changelog is updated with features, bug fixes, and security patches.
- [ ] Git tags are created and pushed to the remote repository.
- [ ] Build artifacts are generated and uploaded to the registry.
