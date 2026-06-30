---
name: api-standards
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized api standards module.
---

# API Standards

## Overview
This document defines the architectural standards, protocols, serialization formats, naming conventions, and security rules for all interfaces built by our organization.

## Purpose
To ensure that all APIs are uniform, secure, performant, and easily consumed by client applications.

## When to Use
- When designing new REST, GraphQL, or gRPC endpoints.
- When modifying existing API structures, parameters, or payloads.
- When creating webhooks or external integrations.

## When NOT to Use
- Do NOT use this document to design internal service class methods or library interfaces.
- Do NOT use this document to describe deployment configurations or docker parameters (use `docker-standards`).

## Principles
1. **Consistency**: Use standardized naming, response structures, and HTTP statuses.
2. **Statelessness**: APIs must not rely on server-side session state; use tokens for state representation.
3. **Backward Compatibility**: Design schemas to be extensible; version APIs when introducing breaking changes.
4. **Robust Validation**: Enforce payload validation at the boundary, returning explicit, standardized error messages.

## Workflow
*Note: This is a standard, not a workflow. See `api-design` workflow for execution steps.*

## Rules
- REST endpoints MUST use plural nouns for resources (e.g., `/api/v1/users`, not `/api/v1/user`).
- Path and query parameters MUST use camelCase (or snake_case as globally configured for the project, but consistently).
- JSON payloads MUST use camelCase for keys.
- You MUST use appropriate HTTP methods: GET (read), POST (create), PUT (replace), PATCH (partial update), DELETE (remove).
- Every error response MUST return a standardized JSON error structure containing a machine-readable code and human-readable message:
  ```json
  {
    "error": {
      "code": "INVALID_INPUT",
      "message": "The email address is improperly formatted.",
      "details": []
    }
  }
  ```
- Public APIs MUST use version prefixes (e.g., `/v1/`, `/v2/`).

## Best Practices
- Implement pagination on all list endpoints using limit/offset or cursor-based pagination.
- Set appropriate caching headers (`Cache-Control`) on GET endpoints containing static or slow-changing data.
- Return `201 Created` with a `Location` header pointing to the new resource upon successful creation.

## Common Mistakes
- Returning `200 OK` for requests that failed (errors should map to 4xx or 5xx ranges).
- Over-fetching: Returning unnecessary database columns in the API response.
- Exposing database primary keys (e.g., auto-incrementing integers) directly; use UUIDs instead.

## Anti-patterns
- **Tunneling**: Running all operations via POST requests to `/api/run` (violates REST semantics).
- **The Chatty API**: Designing endpoints so granularly that clients must make dozen sequential API calls to render a single page.

## Examples
*Example: standard REST endpoint design.*
- GET `/api/v1/orders?limit=10&status=pending` -> Returns page of orders.
- POST `/api/v1/orders` -> Creates order, returns `201 Created`.
- GET `/api/v1/orders/{id}` -> Returns order detail.
- PATCH `/api/v1/orders/{id}` -> Updates order status, returns `200 OK`.
- DELETE `/api/v1/orders/{id}` -> Deletes order, returns `204 No Content`.

## Completion Checklist
- [ ] API endpoints adhere to RESTful / gRPC architectural guidelines.
- [ ] Endpoints use plural nouns and standard HTTP methods.
- [ ] Payload JSON keys follow the designated camelCase standard.
- [ ] Standardized error structure is used for all failure responses.
- [ ] Pagination, versioning, and rate limiting are configured.
