---
name: coding-style
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized coding style module.
metadata:
  short-description: "Standardized Coding Style module."
---

# Coding Style Standards

## Overview
This document outlines core language-agnostic style guidelines, focusing on readability, naming conventions, structural patterns, and code clarity.

## Purpose
To maintain a unified code style across all services, minimizing cognitive load for developers switching systems.

## When to Use
- When writing files in any programming language (Python, TypeScript, Go, etc.).
- When configuring project linters and formatters.

## When NOT to Use
- Do NOT use this document to design database tables (use `database-standards`).
- Do NOT use this document to define Git practices (use `gitflow`).

## Principles
1. **Readability is Paramount**: Code is read far more often than it is written.
2. **KISS (Keep It Simple, Stupid)**: Avoid clever tricks or dense syntax when simple constructs will do.
3. **DRY (Don't Repeat Yourself)**: Eliminate duplicate logic by extracting shared abstractions.
4. **SOLID Principles**: Build object-oriented systems around modular, open-closed, and decoupled abstractions.

## Workflow
*Note: This is a standard.*

## Rules
- Variable, function, and class names MUST be self-descriptive (e.g., `user_registration_timestamp`, not `urt`).
- You MUST use the language-appropriate casing conventions:
  - PascalCase for Class names.
  - camelCase or snake_case for functions and variables (consistently across the project).
  - UPPER_SNAKE_CASE for constant configurations.
- Nesting levels inside functions MUST NOT exceed three tiers deep; refactor deep branches into helper methods.
- You MUST run the project formatter (e.g., Prettier, Black, gofmt) prior to committing code.

## Best Practices
- Limit files to 500 lines and functions to 50 lines to keep them focused.
- Declare variables as close to their first usage as possible.
- Avoid using global variables or mutable global state.

## Common Mistakes
- Creating vague names like `data`, `process`, `handle`, or `temp`.
- Leaving dead code, unused imports, or deactivated functions in files.
- Writing complex single-line statements (e.g., deep ternary chains) that are hard to debug.

## Anti-patterns
- **Spaghetti Code**: Creating chaotic control paths with no structure or boundaries.
- **Lava Flow**: Retaining obsolete code blocks because developers are afraid to remove them.

## Examples
*Example: Refactoring deep nesting.*
```typescript
// Bad: Deep nesting
function processOrder(order) {
  if (order.isActive) {
    if (order.paymentReceived) {
      if (order.inventoryReady) {
        shipOrder(order);
      }
    }
  }
}

// Good: Guard clauses
function processOrder(order) {
  if (!order.isActive) return;
  if (!order.paymentReceived) return;
  if (!order.inventoryReady) return;
  
  shipOrder(order);
}
```

## Completion Checklist
- [ ] Variable and function names are explicit and self-describing.
- [ ] Nested loops and condition blocks are limited to less than three levels.
- [ ] Code is formatted using the project-designated tools.
- [ ] File and function lengths comply with standard limits.
- [ ] Guard clauses are used to eliminate deep indentation.
