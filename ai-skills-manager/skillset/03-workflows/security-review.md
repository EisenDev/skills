---
name: security-review
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["security-first", "api-standards"]
description: Standardized security review module.
metadata:
  short-description: "Standardized Security Review module."
---

# Security Review Workflow

## Purpose
To audit system architectures, database designs, API specifications, and code changes for security vulnerabilities before deployment.

## When to Use
- When completing a major feature design or technical architecture.
- Prior to launching a new system or service.
- During scheduled security audits.

## Required Prerequisite Skills
- `security-first` (to identify threat vectors)
- `api-standards` (to check API security rules)

## Expected Inputs
- Architecture diagrams, API OpenAPI files, and database schemas.
- Code diffs or system specifications.

## Execution Workflow
1. **Analyze Data Flow**: Map out how data enters, traverses, and leaves the system. Identify trust boundaries.
2. **Check Authentication/Authorization**: Ensure every entry point has authentication checks. Apply `api-standards` security rules.
3. **Verify Input Sanitization**: Inspect all input controllers to ensure strict validation schemas are enforced.
4. **Audit Secret Storage**: Ensure credentials, keys, and connection strings are injected via runtime parameters, not hardcoded.
5. **Run Dependency Scan**: Run scans to check for known CVEs in third-party dependencies.
6. **Document Risks**: Write a Security Review report detailing vulnerabilities and required remediations.

## Expected Outputs
- A Security Review report containing identified risks and severity levels.
- Jira / task tickets to address critical vulnerabilities.

## Completion Checklist
- [ ] Trust boundaries and data flows are defined and mapped.
- [ ] Authentication and authorization checks are verified on all endpoints.
- [ ] Input validation rules conform to strict whitelist parameters.
- [ ] Secrets are verified as excluded from code repositories.
- [ ] Security issues are resolved or documented as acceptable risks.
