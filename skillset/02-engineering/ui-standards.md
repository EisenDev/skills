# UI Standards

## Overview
This document defines visual design guidelines, layouts, typography, spacing systems, theme configurations, and component behaviors.

## Purpose
To create visually stunning, cohesive, responsive, and premium user interfaces.

## When to Use
- When writing CSS, configuring theme tokens, or styling components.
- When implementing page layouts, margins, grids, and typography.
- When adding hover effects, transitions, and micro-animations.

## When NOT to Use
- Do NOT use this document to define database schemas (use `database-standards`).
- Do NOT use this document to build functional API endpoints (use `api-standards`).

## Principles
1. **Design Tokens**: Design systems must use variables for colors, spacing, and typography (never hardcoded values).
2. **Visual Hierarchy**: Guide the user's attention through size, weight, contrast, and layout.
3. **Responsive Flow**: Layouts must adapt to different viewports (mobile, tablet, desktop) without broken boxes.
4. **Motion & Feedback**: Provide instant visual feedback for user interactions with subtle, smooth animations.

## Workflow
*Note: This is a standard.*

## Rules
- All colors, fonts, and spacing measurements MUST be derived from predefined CSS variables or Tailwind tokens.
- UI elements MUST NOT clip, overlap, or wrap in an unreadable manner on screen sizes between 320px and 2560px wide.
- Interactive elements (buttons, inputs, links) MUST have explicit `:hover`, `:focus-visible`, and `:active` styles.
- Animations and transitions MUST use subtle durations (e.g., `150ms` to `300ms` max) and smooth easing functions (e.g., `ease-in-out` or `cubic-bezier`).

## Best Practices
- Enforce vertical rhythm by sticking to an 8px grid system for margins and paddings.
- Use Outfit, Inter, or system-ui fonts for text clarity.
- Implement responsive grids with CSS Grid or Flexbox, avoiding absolute positioning for layouts.

## Common Mistakes
- Using pure black (`#000000`) or pure primary colors (pure red, green, blue); use refined neutral scales and HSL colors instead.
- Ignoring focus outlines, making keyboard navigation impossible.
- Over-animating the page, which distracts users and harms performance.

## Anti-patterns
- **The Rainbow UI**: Using more than three primary/secondary color schemes, making the interface look cluttered.
- **Layout Shift**: Changing element sizes or positions during load without skeleton placeholders, causing layout instability (CLS).

## Examples
*Example: CSS Design Tokens and component styling.*
```css
:root {
  --color-primary-base: hsl(220, 90%, 56%);
  --color-neutral-900: hsl(220, 15%, 10%);
  --spacing-md: 16px;
  --transition-smooth: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
}

.btn-primary {
  background-color: var(--color-primary-base);
  padding: var(--spacing-md);
  transition: var(--transition-smooth);
}
.btn-primary:hover {
  filter: brightness(1.1);
}
```

## Completion Checklist
- [ ] Layout is responsive across all major device widths.
- [ ] Colors, fonts, and spacings utilize predefined design variables.
- [ ] Hover, focus, and active states are implemented on interactive elements.
- [ ] Transitions and micro-animations are smooth, subtle, and performant.
- [ ] Zero layout shifting (CLS) is observed during page load.
