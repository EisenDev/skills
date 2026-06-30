---
name: api-design
version: 1.0.0
category: workflow
author: Zeraynce Engineering
dependencies: ["api-standards", "documentation-first"]
description: Standardized api design module.
---

# API Design Workflow

## Purpose
To design readable, structured, versioned, and contract-first interfaces that expose system functionality.

## When to Use
- Before creating a new API endpoint or modifying existing request/response structures.

## Required Prerequisite Skills
- `api-standards` (to apply protocol and formatting guidelines)
- `documentation-first` (to draft interface specifications before coding)

## Expected Inputs
- Functional requirements (data to be exchanged, operations needed).
- Access to client developer requirements.

## Execution Workflow
1. **Gather Requirements**: Identify what resources need to be queried or mutated and by whom.
2. **Draft OpenAPI/Schema Contract**: Use `documentation-first` to write an OpenAPI specification (or protobuf for gRPC).
3. **Apply API Standards**: Ensure paths, HTTP methods, headers, status codes, and error structures conform to `api-standards`.
4. **Define Security Scope**: Specify what authentication scopes or roles are required to access each endpoint.
5. **Review Spec**: Present the spec to frontend and client team developers. Ensure request and response payloads fit client UI flows.
6. **Commit the Contract**: Merge the schema file into the repository before starting backend coding.

## Expected Outputs
- A finalized OpenAPI YAML, GraphQL Schema, or Protobuf file.
- Approved API contract committed to the repository.

## Completion Checklist
- [ ] API contract is written using OpenAPI, GraphQL, or Protobuf formats.
- [ ] Request parameters and response fields use standardized casing (camelCase).
- [ ] Error response structures conform to the standard error JSON schema.
- [ ] Authentication and role requirements are documented for each route.
- [ ] Consumers have reviewed and signed off on the interface structure.
