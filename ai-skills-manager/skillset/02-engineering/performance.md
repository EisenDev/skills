---
name: performance
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized performance module.
metadata:
  short-description: "Standardized Performance module."
---

# Performance Standards

## Overview
This document defines guidelines for backend computational complexity, memory management, database interactions, and network utilization.

## Purpose
To build fast, resource-efficient, and responsive services that scale under high user load.

## When to Use
- When writing backend logic, loops, and data processors.
- When planning caching layers.
- When writing database queries and transaction scopes.

## When NOT to Use
- Do NOT use this document to design layout margins or buttons (use `ui-standards`).
- Do NOT use this document to define linter rules (use `quality-gates`).

## Principles
1. **Measure First**: Never optimize performance without empirical benchmark data or profiling traces.
2. **Caching Strategy**: Cache data that is expensive to compute, frequently accessed, and slow to change.
3. **Database Efficiency**: Minimizing round-trips and using indexes is the highest-leverage performance optimization.
4. **Resource Economy**: Use streams and pagination to handle large datasets instead of buffering them in memory.

## Workflow
*Note: This is a standard.*

## Rules
- You MUST NOT read large datasets entirely into memory; utilize database pagination or stream files.
- Loops that perform network requests or database queries (N+1 query pattern) MUST be refactored into batch operations.
- Long-running transactions MUST be kept brief to avoid holding database locks and blocking connection pools.
- Heavy operations (e.g. PDF generation, image processing) MUST be offloaded to asynchronous background queues.

## Best Practices
- Use Redis or Memcached for low-latency cache stores with explicit TTL configurations.
- Use connection pooling for all database and external API integrations.
- Minify and compress static assets (Brotli/Gzip) before delivery.

## Common Mistakes
- Caching data indefinitely without defining TTL expiration parameters (causes memory bloat and stale data).
- Performing computations in database queries when they could be processed in application memory.
- Optimizing code blocks that run rarely, wasting developer effort.

## Anti-patterns
- **The Memory Buffer**: Loading an entire 1GB database table into server RAM to filter it inside application loops.
- **Unbounded Queries**: Executing query logic without limits, causing database crashes when tables grow.

## Examples
*Example: Refactoring N+1 queries.*
```python
# Bad: Query in loop (N+1)
for user in users:
    posts = db.query("SELECT * FROM posts WHERE author_id = ?", user.id)

# Good: Batch query
user_ids = [user.id for user in users]
all_posts = db.query("SELECT * FROM posts WHERE author_id IN (?)", user_ids)
# Map posts to users in application memory
```

## Completion Checklist
- [ ] Database queries are verified to utilize indexes.
- [ ] Large files and datasets are processed using streams/chunking.
- [ ] Caching layers have TTL parameters defined.
- [ ] Computational tasks avoid N+1 network patterns.
- [ ] Benchmarking or query plans have been run and verified.
