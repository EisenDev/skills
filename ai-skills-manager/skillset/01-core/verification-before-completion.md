---
name: verification-before-completion
version: 1.0.0
category: core
author: Zeraynce Engineering
dependencies: []
description: Standardized verification before completion module.
---

# Verification Before Completion

## Overview
This skill governs the checks that must be executed *after* development is completed but *before* code is submitted for code review or merged. It ensures the implementation functions correctly in a target environment.

## Purpose
To verify that changes meet specifications, contain no regressions, run correctly, and comply with all core guidelines.

## When to Use
- Immediately after writing feature code or bug fixes.
- Before opening a Pull Request (PR) or moving a ticket to "Ready for Review".
- After resolving conflicts or rebasing.

## When NOT to Use
- Do NOT use this skill during the planning or initial drafting of requirements (use `documentation-first`).
- Do NOT use this skill to perform automated CI quality checks (use `quality-gates`).

## Principles
1. **Trust, but Verify**: Never assume code is correct because "it compiled" or "tests passed on CI."
2. **Real-world Context**: Test features using parameters, inputs, and database states that match production structures.
3. **Zero Leftover State**: Clean up configuration overrides, test users, and temporary files.

## Workflow
1. **Local Clean Build**: Compile the application and run the complete test suite locally in a clean state.
2. **Manual Target Verification**: Manually execute the user flow or invoke the API endpoint in a local/staging environment.
3. **Regression Check**: Run tests on adjacent components that were not modified but could be affected.
4. **Log & Metric Review**: Inspect local server logs during execution to verify there are no unexpected warnings or errors.
5. **PR Draft Review**: Inspect the final git diff line-by-line to ensure no accidental changes or debugging tools are present.

## Rules
- You MUST manually execute and verify the implemented behavior at least once.
- The git diff MUST be reviewed line-by-line for clean formatting, console logs, and TODOs before submission.
- You MUST verify that the changes work correctly in the target environment (e.g. Docker container, dev server).

## Best Practices
- Keep a checklist of user scenarios to run through before finalizing the feature.
- Test under negative conditions (empty databases, disconnected networks, invalid inputs).
- Capture screenshots, API payloads, or screen recordings for complex UI changes to attach to the PR.

## Common Mistakes
- Submitting code for review without testing it end-to-end because "the unit tests passed."
- Leaving commented-out code block structures or debug statements in the final PR.
- Testing only the positive path and ignoring error paths.

## Anti-patterns
- **The "Works on My Machine" Shield**: Declaring a ticket complete when it fails in staging, citing local environment differences instead of fixing the issue.
- **Diff Blindness**: Committing files without reviewing the git diff, leading to configuration leaks or stray files.

## Examples
*Example: Finalizing a payment gateway integration.*
1. Test local suite: `npm test` -> all green.
2. Run server, execute mock purchase of $10.00. Check payment provider sandbox dashboard -> purchase registered.
3. Check database user state -> status updated to "active_subscription".
4. Review logs -> no stack traces or raw credit card data.
5. Run `git diff` -> remove debug `console.log("PAYMENT:", payload)` in gateway controller. Commit and open PR.

## Completion Checklist
- [ ] Code compiles and all automated tests pass locally.
- [ ] Manual verification of the feature/bug fix has been completed.
- [ ] System logs have been checked for unexpected warnings or errors during runtime.
- [ ] Complete git diff has been reviewed line-by-line.
- [ ] No temporary debug code or environment variables are left in source files.
