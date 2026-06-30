# Logging Standards

## Overview
This document defines rules for logging structure, log levels, log sanitization, and output mechanisms.

## Purpose
To generate searchable, structured, and informative logs that simplify system observability and incident triage.

## When to Use
- When writing logger statements in application code.
- When configuring centralized log aggregators (e.g. ELK, Datadog).
- When resolving production errors.

## When NOT to Use
- Do NOT use this document to format user-facing API error payloads (use `api-standards`).
- Do NOT use this document to structure git commit records (use `gitflow`).

## Principles
1. **Structured Format**: Logs must output as structured JSON objects, enabling query aggregations.
2. **Context Enrichment**: Include core trace identifiers (e.g., `trace_id`, `user_id`) in every log context block.
3. **No Sensitivity**: Never output secrets, passwords, or PII into logs.
4. **Log Appropriately**: Assign correct logging levels (DEBUG, INFO, WARN, ERROR) to prevent alert fatigue.

## Workflow
*Note: This is a standard.*

## Rules
- Production application logs MUST be emitted to standard output (`stdout`) in JSON format.
- You MUST sanitize logs, scrubbing values associated with keys like `password`, `token`, `credit_card`, and `ssn`.
- You MUST use log levels correctly:
  - `DEBUG`: Internal execution steps, parameters, database outputs (disabled in production).
  - `INFO`: Normal system landmarks (e.g., transaction started, server listening).
  - `WARN`: Non-fatal issues (e.g., slow query, retry attempt, deprecation notice).
  - `ERROR`: System failures requiring developer action (e.g., uncaught exception, database down).
- You MUST include a unique trace identifier in log statements matching a web request or background job lifecycle.

## Best Practices
- Log messages should be static templates; use context objects for variable details (e.g., `log.info("Order processed", { order_id: 123 })` instead of `log.info("Order processed for id " + 123)`).
- Log downstream connection times to help isolate network latency.
- Set log rotation on local development volumes to prevent disk exhaustion.

## Common Mistakes
- Logging string tracebacks as unstructured text fields, breaking JSON index parsers.
- Flooding the logs with repetitive messages inside loops (causes write bottleneck).
- Throwing exceptions without logging the trace stack details.

## Anti-patterns
- **The Black Hole**: Capturing exceptions silently with an empty catch block, leaving no log trail of the failure.
- **Log Noise**: Logging everything as INFO or ERROR, rendering log streams unreadable.

## Examples
*Example: Structured Log format.*
```json
{
  "timestamp": "2026-06-29T13:35:10.123Z",
  "level": "INFO",
  "message": "User checkout successful",
  "trace_id": "c8b9d21a-3e91-4cfb-810a-b31a54a7f052",
  "context": {
    "user_id": "usr_9921",
    "order_id": "ord_8829",
    "amount_usd": 120.50
  }
}
```

## Completion Checklist
- [ ] Logs emit in structured JSON formats to stdout.
- [ ] Log levels conform to standardized definition rules.
- [ ] Logging logic sanitizes sensitive fields and PII.
- [ ] Dynamic values are placed in context maps, not message text.
- [ ] Tracing IDs are linked across log sequences.
