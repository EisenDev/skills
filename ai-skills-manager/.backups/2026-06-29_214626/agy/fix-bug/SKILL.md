---
name: fix-bug
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["systematic-debugging", "root-cause-analysis", "testing-first", "architecture-thinking", "verification-before-completion"]
description: Standardized fix bug module.
---

# Fix Bug Workflow

## Purpose
To systematically identify, verify, repair, and deploy corrections for software anomalies while ensuring zero regressions.

## When to Use
- When resolving a bug ticket, user issue, or failed test suite.

## Required Prerequisite Skills
- `systematic-debugging` (to isolate variables and locate the bug)
- `root-cause-analysis` (to understand why the failure occurred)
- `testing-first` (to write regression tests before writing the fix)
- `architecture-thinking` (to ensure the fix aligns with design principles)
- `verification-before-completion` (to test and inspect the fix)

## Expected Inputs
- A ticket containing reproduction details, logs, or error descriptions.
- Access to the target codebase.

## Execution Workflow
1. **Isolate and Reproduce**: Run the system locally and execute the `systematic-debugging` workflow. Pinpoint the exact file and lines containing the bug.
2. **Find the Root Cause**: Execute the `root-cause-analysis` workflow (5 Whys). Identify the architectural or process failure that let this bug pass.
3. **Write a Regression Test**: Invoke `testing-first`. Write an automated test that reproduces the bug (demonstrates the failure). Verify the test fails.
4. **Formulate the Fix**: Use `architecture-thinking` to plan a correction that preserves system boundaries. Do not use band-aid patches.
5. **Implement the Fix**: Write code to make the regression test pass. Ensure other tests remain green.
6. **Verify the Fix**: Apply `verification-before-completion` by reviewing the git diff, checking logs, and testing edge cases.

## Expected Outputs
- A clean git commit containing the passing regression test and the bug correction.
- An update to the bug ticket explaining the root cause and the resolution.

## Completion Checklist
- [ ] Bug has been successfully reproduced locally.
- [ ] Root cause analysis has been performed and documented.
- [ ] An automated test reproduces the bug and now passes.
- [ ] Code modifications conform to backend/frontend and coding style standards.
- [ ] Git diff has been reviewed, and the fix is verified to contain no regressions.
