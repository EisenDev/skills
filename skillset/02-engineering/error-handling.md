# Error Handling Standards

## Overview
This document defines strategies for error propagation, exception routing, response isolation, and recovery.

## Purpose
To build resilient backend architectures that fail gracefully and present readable diagnostics without crashing.

## When to Use
- When handling exceptions or error values in business logic.
- When configuring API controller error filters.
- When writing retry logic.

## When NOT to Use
- Do NOT use this document to format front-end style guidelines (use `ui-standards`).
- Do NOT use this document to create test mocks (use `testing-first`).

## Principles
1. **Explicit Return vs Exception**: Use return errors for expected operational failures (validation, not found) and exceptions for unexpected anomalies (database connection loss).
2. **Crash Safely**: If an uncaught exception corrupts application state, crash the process immediately and let the orchestrator restart it.
3. **No Data Leak**: Never return raw stack traces or internal environment variables to client applications.
4. **Error Ownership**: Ensure every error is caught, handled, or logged at the correct boundary level.

## Workflow
*Note: This is a standard.*

## Rules
- You MUST NOT catch exceptions without either handling the error, wrapping it with context, or logging the failure.
- User-facing error messages MUST NOT contain raw stack traces or SQL error codes.
- System boundaries (e.g. API endpoints, consumer loops) MUST catch uncaught exceptions to prevent worker exit.
- HTTP status codes MUST map correctly to categories:
  - `400 Bad Request`: Validation failure.
  - `401 Unauthorized`: Authentication required or token expired.
  - `403 Forbidden`: Authenticated user lacks access to the resource.
  - `404 Not Found`: Target resource does not exist.
  - `429 Too Many Requests`: Rate limit reached.
  - `500 Internal Server Error`: Unexpected system failure.

## Best Practices
- Define custom application error classes that contain metadata and error codes.
- Implement exponential backoff retry parameters when contacting flaky downstream APIs.
- Validate inputs early in the request execution cycle using guard clauses.

## Common Mistakes
- Catching general exceptions (e.g. `catch (Exception e)`) and doing nothing, masking real system issues.
- Using exceptions for basic control flow (e.g., throwing a `UserNotFoundException` during a normal email lookup check).
- Logging an error multiple times as it bubbles up through call stacks.

## Anti-patterns
- **The Empty Catch**: Silently swallowing errors, rendering bugs impossible to detect.
- **Generic Error 500**: Returning "Internal Server Error" for user-corrected issues like input validation.

## Examples
*Example: Custom exception wrapper in Node.js.*
```javascript
class DomainError extends Error {
  constructor(code, message, status = 400) {
    super(message);
    this.code = code;
    this.status = status;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Usage
if (!user) {
  throw new DomainError('USER_NOT_FOUND', 'User does not exist.', 404);
}
```

## Completion Checklist
- [ ] Errors are divided into operational (returned) and programmer (thrown) categories.
- [ ] Uncaught exceptions are handled at the system boundary.
- [ ] Raw stack traces are hidden from user API payloads.
- [ ] Correct HTTP/gRPC status codes are returned for error states.
- [ ] Retries use exponential backoff and maximum retry caps.
