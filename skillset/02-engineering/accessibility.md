# Accessibility Standards

## Overview
This document defines Web Content Accessibility Guidelines (WCAG) compliance rules, keyboard navigation standards, and screen reader compatibility requirements.

## Purpose
To build inclusive digital interfaces that are accessible to all users, including those with disabilities.

## When to Use
- When writing HTML, JSX, or web templates.
- When designing UI layouts, contrast ratios, and color palettes.
- When implementing interactive components.

## When NOT to Use
- Do NOT use this document to write Docker container configuration logic (use `docker-standards`).
- Do NOT use this document to manage database schema updates (use `database-standards`).

## Principles
1. **Semantic HTML**: Use native browser tags for their intended purposes to preserve accessibility roles.
2. **Perceivable Content**: Provide text alternatives for non-text content, and ensure high color contrast.
3. **Operable Interface**: All interactive features must be navigable via keyboard commands.
4. **Robust & Predictable**: Ensure code complies with parsing standards and behaves consistently across assistive technologies.

## Workflow
*Note: This is a standard.*

## Rules
- Every image element MUST contain a descriptive `alt` attribute (or an empty `alt=""` if decorative).
- Visual color contrast ratios MUST meet WCAG AA requirements (minimum 4.5:1 for regular text, 3:1 for large text).
- All interactive controls MUST be focusable via the keyboard (using natural tab flow or `tabindex="0"`).
- Dynamic actions (like dropdown expansions, modals) MUST update corresponding ARIA attributes (e.g., `aria-expanded`, `aria-hidden`).

## Best Practices
- Never use color as the sole visual cue to convey state or instructions.
- Ensure form inputs are explicitly linked to corresponding labels using `id` and `for` attributes.
- Support page zooming up to 200% without layout disruption.

## Common Mistakes
- Using non-interactive tags (like `<div>` or `<span>`) to build buttons, breaking keyboard tab structures.
- Hiding outline rings on focused components, making screen navigation impossible.
- Using ambiguous link labels like "click here" or "read more."

## Anti-patterns
- **The ARIA Wall**: Adding excessive, redundant, or incorrect ARIA labels that confuse screen readers.
- **Keyboard Traps**: Creating modal views that capture keyboard focus and prevent users from tabbing out.

## Examples
*Example: Accessible form control and button.*
```html
<!-- Accessible Form Input -->
<label for="user-email">Email Address</label>
<input type="email" id="user-email" name="email" required aria-describedby="email-hint">
<span id="email-hint">Format: name@domain.com</span>

<!-- Accessible Custom Button -->
<button type="button" aria-expanded="false" onclick="toggleMenu()">
  Menu
</button>
```

## Completion Checklist
- [ ] HTML semantic structures are validated (correct `main`, `nav`, `button`).
- [ ] Color contrast ratios meet WCAG AA standards.
- [ ] Interface is fully navigable using Tab, Enter, Space, and arrow keys.
- [ ] Form controls have matching label identifiers.
- [ ] Screen reader annotations (ARIA attributes) reflect dynamic state changes.
