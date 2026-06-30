---
name: systematic-debugging
version: 1.0.0
category: core
author: Zeraynce Engineering
dependencies: []
description: Standardized systematic debugging module.
---

# Systematic Debugging

## Overview
This skill defines the methodology for isolating, reproducing, and identifying the exact locus of code anomalies. It emphasizes hypothesis-driven isolation and scientific exclusion over trial-and-error changes.

## Purpose
To locate the exact line, module, or state configuration causing a software failure by systematically eliminating variables and verifying assumptions.

## When to Use
- When a bug report or test failure is received.
- When an unexpected behavior is observed in code execution.
- When tracebacks or error messages do not immediately pinpoint the root issue.

## When NOT to Use
- Do NOT use this skill for implementing new features.
- Do NOT use this skill to write regression tests or verify code changes (use `testing-first` or `verification-before-completion`).
- Do NOT use this skill for finding the business impact or preventing recurrence (use `root-cause-analysis`).

## Principles
1. **Hypothesis-Driven**: Always form a clear, testable hypothesis before changing any code or running diagnostics.
2. **Variable Isolation**: Change only one variable at a time when attempting to isolate the bug.
3. **Execution Tracing**: Trace control flow and data flow step-by-step from a known good state to the failure point.
4. **No Assumptions**: Verify every assumption; never assume a library, framework, or utility is working correctly without checking its state.

## Workflow
1. **Capture the failure state**: Document the input, expected output, and actual output.
2. **Formulate a hypothesis**: State the specific component and state transition believed to be faulty.
3. **Isolate the scope**: Disable unrelated modules, stub external calls, or simplify inputs until the minimum reproducible example is found.
4. **Trace variables**: Inject logging, use debuggers, or print state at critical control boundaries.
5. **Prove or disprove the hypothesis**: If disproven, document the result and formulate a new hypothesis. If proven, specify the exact locus of the bug.

## Rules
- You MUST write down the hypothesis and current test variables before executing a debugging run.
- Do NOT modify codebase state (outside of temporary debug print statements) during isolation.
- You MUST clean up all debug logs, print statements, or debug configuration before declaring the debugging step complete.

## Best Practices
- Use binary search on git history (`git bisect`) for regression debugging.
- Run the system with minimal configuration to rule out environment interference.
- Log intermediate variables at the borders of untrusted boundaries.

## Common Mistakes
- Randomly changing code lines hoping to fix the issue.
- Assuming the error message's stack trace line is the absolute source of the logic error (it is often just where the error manifested).
- Forgetting to revert debug logs or test modifications.

## Anti-patterns
- **Voodoo Debugging**: Making changes without understanding why they work, simply because the error disappeared.
- **Shotgun Debugging**: Modifying multiple files or parameters simultaneously in a single iteration.

## Examples
*Example: Isolating a null pointer exception in a user data parser.*
1. **Hypothesis**: The parser fails when the input contains an empty middle name string.
2. **Isolation**: Strip the JSON payload to only `{"first_name": "A", "middle_name": "", "last_name": "B"}`.
3. **Verification**: Run parser with stripped JSON. Bug reproduces.
4. **Locus identification**: Trace to `parser.py:line 45` where `middle_name.strip()` is called without a null check.

## Completion Checklist
- [ ] Failure state has been captured and documented.
- [ ] Minimum reproducible input/state has been isolated.
- [ ] Hypothesis has been formulated and validated.
- [ ] Locus of the failure is identified (filename, line number, and state conditions).
- [ ] Temporary debugging lines/configurations have been fully cleaned up.
