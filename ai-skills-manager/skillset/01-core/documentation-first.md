---
name: documentation-first
version: 1.0.0
category: core
author: Zeraynce Engineering
dependencies: []
description: Standardized documentation first module.
metadata:
  short-description: "Standardized Documentation First module."
---

# Documentation First

## Overview
This skill enforces writing the user documentation, API references, configuration guides, and design specifications BEFORE writing any executable implementation code. It ensures documentation is a source of truth for planning and contract validation.

## Purpose
To align stakeholders, clarify requirements, and define system contracts before code is created.

## When to Use
- Before designing or implementing a new public-facing or internal API.
- Before developing command-line flags, configuration structures, or user interfaces.
- Prior to starting any feature development.

## When NOT to Use
- Do NOT use this skill for internal debugging processes or systematic analysis of bugs.
- Do NOT use this skill to write system standards or rules (which are defined in `02-engineering` documents).

## Principles
1. **Documentation is the Design**: Writing the manual or API contract forces the designer to think through the developer experience and system usability.
2. **Contract as Truth**: The documented interfaces act as the binding contract for frontend/backend or service/client development.
3. **Zero Ambiguity**: Use precise language and explicit parameters in documentation.

## Workflow
1. **Draft User Documentation/API Spec**: Write the OpenAPI spec, Markdown guide, or README describing the new feature.
2. **Define Input/Output**: Specify every configuration parameter, CLI option, API parameter, and exact JSON payloads.
3. **Review with Consumers**: Ensure the proposed interfaces fit the consumers' workflows.
4. **Iterate**: Adjust the documentation based on feedback.
5. **Lock Contract**: Freeze the documentation and begin implementation to match the defined spec.

## Rules
- You MUST create or update the API schema (e.g., OpenAPI yaml) or user README before writing implementation code.
- Functional implementation code MUST match the documented specifications exactly.
- Documentation MUST include concrete examples of usage, inputs, outputs, and errors.

## Best Practices
- Write documentation in clear, declarative markdown.
- Include failure modes and error responses in the documentation.
- Maintain documentation in the same repository as the code.

## Common Mistakes
- Writing implementation code first and then auto-generating docs from the code (this bypasses design validation).
- Using placeholder descriptions (e.g., "id: the ID of the object").
- Letting documentation drift from the actual code.

## Anti-patterns
- **Ghost Documentation**: Documentation that describes a phantom interface that is never implemented or diverges wildly.
- **The Spec Sphinx**: Writing documentation that lists inputs but omits their formats, constraints, or defaults.

## Examples
*Example: Designing a user-update API endpoint.*
1. Draft `openapi.yaml` mapping `/api/v1/users/{id}` (PATCH).
2. Specify request body: `name` (string, max 50 chars, optional), `email` (string, RFC 5322 format, optional).
3. Specify responses: `200 OK` with updated user object, `400 Bad Request` with structured validation errors, `404 Not Found`.
4. Review with frontend team, refine constraints, then commit `openapi.yaml` before coding.

## Completion Checklist
- [ ] README, API specifications, or configuration schemas are written.
- [ ] Examples of successful and failed executions are included.
- [ ] Stakeholders/consumers have reviewed and accepted the interfaces.
- [ ] Documentation is committed to the repository as the development contract.
