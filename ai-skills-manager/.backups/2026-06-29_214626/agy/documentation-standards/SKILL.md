---
name: documentation-standards
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized documentation standards module.
---

# Documentation Standards

## Overview
This document defines standards for repository markdown structures, API references, inline code comments, and Architecture Decision Records (ADRs).

## Purpose
To ensure all technical documentation is readable, maintainable, searchable, and structured.

## When to Use
- When writing README files or repository wikis.
- When creating Architecture Decision Records (ADRs).
- When writing inline code docstrings and comments.

## When NOT to Use
- Do NOT use this document to structure git workflows (use `gitflow`).
- Do NOT use this document to formulate software architectures (use `architecture-thinking`).

## Principles
1. **Living Documentation**: Documentation must reside alongside the code, updating as features change.
2. **Clarity over Cleverness**: Write documents using simple, clear, and direct prose.
3. **Structured & Searchable**: Use consistent markdown headers and metadata properties.
4. **Audience Aware**: Tailor document style (user guide, API spec, developer onboarding) to its intended reader.

## Workflow
*Note: This is a standard.*

## Rules
- Every repository MUST contain a root `README.md` containing onboarding instructions, stack details, and execution commands.
- All code modules, classes, and public methods MUST have inline docstrings explaining inputs, outputs, and side effects.
- Architectural pivots or system additions MUST be recorded via an Architecture Decision Record (ADR) file.
- Inline comments MUST explain *why* a complex logic block was written, not *what* the code is doing (which should be clear from readable code).

## Best Practices
- Format all markdown documents to wrap at 80 or 120 characters for editor readability.
- Validate documentation links to prevent broken references.
- Use visual diagrams (Mermaid, PNG) to explain complex workflows.

## Common Mistakes
- Writing outdated documentation and forgetting to update it when logic changes.
- Writing redundant comments (e.g., `i = i + 1 // increment i by 1`).
- Writing essays inside code blocks instead of extracting logic into readable functions.

## Anti-patterns
- **The Stale Scroll**: Maintaining documentation wiki pages outside the git tree, which decay rapidly.
- **The Ghost Code**: Writing undocumented configuration options that only the author knows how to use.

## Examples
*Example: Python docstring standard.*
```python
def calculate_interest(principal: float, rate: float, term_days: int) -> float:
    """Calculates simple daily interest for a lending account.

    Args:
        principal: The initial loan balance (must be positive).
        rate: Annual interest rate as a decimal (e.g., 0.05 for 5%).
        term_days: Duration of the loan calculation in days.

    Returns:
        The total interest accumulated over the term.

    Raises:
        ValueError: If principal or term_days is negative.
    """
```

## Completion Checklist
- [ ] Root README.md is present and contains setup and execution steps.
- [ ] Public classes, functions, and modules contain structured docstrings.
- [ ] Inline comments explain the "why" of complex logic.
- [ ] Architecture modifications are documented via ADR files.
- [ ] All code links and references are verified as working.
