---
name: frontend-standards
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized frontend standards module.
metadata:
  short-description: "Standardized Frontend Standards module."
---

# Frontend Standards

## Overview
This document defines frontend development standards, focusing on state management, hydration, rendering strategies, caching, and performance optimizations.

## Purpose
To build responsive, fast-loading, and clean web applications that render consistently across clients.

## When to Use
- When building frontend web applications (e.g., React, Next.js, Vue).
- When configuring build tools, bundlers, and static asset deployment.

## When NOT to Use
- Do NOT use this document to outline styling details, fonts, or colors (use `ui-standards`).
- Do NOT use this document to design database tables (use `database-standards`).

## Principles
1. **Performance Budget**: Minimize bundles, optimize images, and defer non-critical scripts.
2. **Component Isolation**: Components should be modular, reusable, and self-contained.
3. **State Hygiene**: Keep local state local; use global state stores only for truly global data.
4. **Hydration & SEO**: Choose appropriate rendering methods (SSR, SSG, CSR) based on content structure and SEO needs.

## Workflow
*Note: This is a standard.*

## Rules
- Large third-party libraries MUST be imported dynamically (code-splitting) to reduce main bundle weight.
- You MUST define explicit typescript typings (no `any`) for all component interfaces and API responses.
- Application state MUST be synced with routing states (URLs) when representing search filters, tabs, or modal views.
- Frontend assets MUST be served with aggressive caching headers (`Cache-Control: max-age=31536000, immutable`) for contenthashed bundles.

## Best Practices
- Use custom hooks to decouple business logic from component rendering.
- Defer non-critical CSS and JS files using `defer` or `async` tags.
- Optimize images using modern formats (WebP, AVIF) with appropriate size variations (`srcset`).

## Common Mistakes
- Storing large datasets in global state stores, leading to sluggish rendering and memory leaks.
- Rendering raw HTML strings without sanitization, introducing XSS risks.
- Fetching API data in component rendering loops without dependency arrays, triggering infinite API calls.

## Anti-patterns
- **The Monolithic Component**: Writing files containing thousands of lines of markup, state, and logic.
- **Prop Drilling**: Passing state down through dozens of nested component levels rather than using React Context or composition.

## Examples
*Example: Code-splitting and dynamic importing.*
```typescript
import dynamic from 'next/dynamic';

const DynamicChart = dynamic(() => import('@/components/AnalyticsChart'), {
  loading: () => <p>Loading Analytics Chart...</p>,
  ssr: false, // Defer rendering until client-side hydration
});
```

## Completion Checklist
- [ ] Application uses TypeScript with zero `any` definitions.
- [ ] Bundle size optimization and dynamic imports are configured.
- [ ] Rendering strategy (SSR/SSG/CSR) is optimized for the page's use case.
- [ ] State management patterns avoid prop drilling and excessive renders.
- [ ] Assets are configured with cache busting and CDN-ready headers.
