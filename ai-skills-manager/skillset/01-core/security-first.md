---
name: security-first
version: 1.0.0
category: core
author: Zeraynce Engineering
dependencies: []
description: Standardized security first module.
metadata:
  short-description: "Standardized Security First module."
---

# Security First

## Overview
This skill focuses on proactive threat modeling, vulnerability reduction, and adhering to security principles at all stages of development. It prevents security vulnerabilities from being introduced into codebase architectures.

## Purpose
To identify threat vectors, validate inputs, enforce authentication/authorization, and protect sensitive data before and during implementation.

## When to Use
- When designing network-accessible components, APIs, or storage.
- When processing untrusted user input or uploading files.
- When handling credentials, secrets, or personally identifiable info (PII).

## When NOT to Use
- Do NOT use this skill for configuring CI/CD pipelines (use `docker-standards` or `deployment`).
- Do NOT use this skill to document standards for database migrations (use `database-standards`).

## Principles
1. **Least Privilege**: Grant the minimum permissions required to perform an action.
2. **Defense in Depth**: Rely on multiple layered defense checks rather than a single security boundary.
3. **Never Trust User Input**: Sanitize, normalize, and validate all inputs at the boundary.
4. **Secure Defaults**: Configure systems to be secure out of the box (e.g., closed ports, authentication required, secure cookies).

## Workflow
1. **Perform Threat Modeling**: Identify assets, entry points, data flows, and potential threat actors.
2. **Define Security Requirements**: Determine necessary encryption (in-transit/at-rest), authentication mechanisms, and access controls.
3. **Implement Input Validation**: Define strict schemas, data types, and length restrictions.
4. **Manage Secrets**: Ensure secrets are injected at runtime via environment variables, never hardcoded.
5. **Validate Output**: Sanitize and escape outputs to prevent XSS, injection, or data leaks.

## Rules
- You MUST NOT commit API keys, passwords, certificates, or tokens to source control.
- All external data (parameters, headers, query variables) MUST be validated against a whitelist schema.
- Data containing PII MUST be encrypted at rest and masked in logs.
- Dependencies MUST be scanned for known CVEs before being merged.

## Best Practices
- Use parameterized queries or ORMs to prevent SQL injection.
- Implement rate limiting on public endpoints to prevent DoS.
- Enforce HTTPS and secure headers (HSTS, CSP, X-Frame-Options).

## Common Mistakes
- Relying on client-side validation as the sole security control.
- Logging raw request bodies that contain passwords or credit card numbers.
- Assuming internal networks are safe and disabling authentication on internal APIs.

## Anti-patterns
- **Security through Obscurity**: Hiding secrets in source code files under misleading names or hoping endpoints remain undiscovered.
- **The Blind Trust**: Accepting payloads from third-party systems without verifying webhooks or signatures.

## Examples
*Example: Threat modeling a profile picture upload feature.*
1. **Threat**: Uploading executable script files (RCE).
2. **Mitigation**: Validate file extensions and magic bytes (ensure it is a valid image), store uploaded files in a sandbox environment (e.g., S3) with execution disabled, and serve files with `Content-Type: image/png` headers.

## Completion Checklist
- [ ] Threat modeling has been completed for the feature.
- [ ] Strict whitelist input validation is defined and implemented.
- [ ] Secrets are stored outside of source control.
- [ ] Access controls and encryption schemes have been verified.
- [ ] OWASP top-10 vulnerabilities have been systematically reviewed and mitigated.
