# Testing First

## Overview
This skill governs the methodology of designing, writing, and executing test suites prior to or in parallel with writing implementation code. It ensures that requirements are mathematically and logically specified as tests before functional code is written.

## Purpose
To build a safety net of automated tests that define the expected behavior of code and prevent regressions.

## When to Use
- Before writing any new function, class, or endpoint.
- Before modifying existing behavior or refactoring.
- When writing bug regression tests.

## When NOT to Use
- Do NOT use this skill for exploring APIs or prototyping non-production sandboxes where specifications are entirely unknown.
- Do NOT use this skill for investigating production crashes or tracing control flows (use `systematic-debugging` or `root-cause-analysis`).

## Principles
1. **Red-Green-Refactor**: Write a failing test first (Red), implement the minimum code to make it pass (Green), then clean up the implementation (Refactor).
2. **Clear Boundaries**: Separate unit, integration, and end-to-end tests clearly.
3. **Determinism**: Tests must yield identical results regardless of execution order or external environment.
4. **Behavior-Centric**: Test contract behavior and public APIs, not internal private implementation details.

## Workflow
1. **Analyze Specifications**: Determine inputs, preconditions, expected outputs, and error conditions.
2. **Write the Test Case**: Define the test setup, action (invocation), and assertion.
3. **Execute and Fail (Red)**: Run the test to ensure it fails for the expected reason, confirming the test is valid.
4. **Write Minimum Implementation**: Write the simplest code that passes the test.
5. **Execute and Pass (Green)**: Run the test suite to confirm it passes.
6. **Refactor**: Clean up code structure, style, and comments while keeping the test green.

## Rules
- You MUST write at least one unit test before writing the corresponding functional code.
- You MUST verify that the test fails (Red phase) before writing the implementation to avoid false positives.
- Test names MUST explicitly describe the scenario and expected outcome (e.g., `test_withdraw_fails_when_balance_insufficient`).
- External network, database, or filesystem calls in unit tests MUST be mocked or stubbed.

## Best Practices
- Keep tests fast; group database or network tests into a separate integration suite.
- Cover boundary conditions (empty values, overflow values, nulls, invalid formats).
- Assert specific exception types and error messages in failure tests.

## Common Mistakes
- Writing tests that assert nothing (only verifying no exception is thrown, missing state verification).
- Writing tests after the implementation and tweaking them to pass.
- Mocking the system under test itself.

## Anti-patterns
- **The Screenplay**: Writing tests that assert exact execution logs or private variables, causing high test fragility.
- **The Liar**: A test that passes even when the underlying implementation is broken due to excessive mocking or incorrect assertions.

## Examples
*Example: Implementing a currency formatter.*
1. **Test Case**: Input `1234.56` formatted as USD returns `"$1,234.56"`.
2. **Red**: Run test. It fails because the formatter class does not exist.
3. **Implementation**: Write class with stub. Run test. It fails with empty string.
4. **Green**: Implement formatting logic. Run test. It passes.
5. **Refactor**: Optimize string allocation. Ensure test remains green.

## Completion Checklist
- [ ] Test cases cover standard paths, edge cases, and invalid inputs.
- [ ] Tests have been executed and observed to fail before implementation.
- [ ] Functional code has been written and all tests pass.
- [ ] Code has been refactored and tests remain green.
- [ ] No external dependencies are hit in unit tests without mocking.
