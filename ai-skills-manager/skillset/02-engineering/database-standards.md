---
name: database-standards
version: 1.0.0
category: engineering
author: Zeraynce Engineering
dependencies: []
description: Standardized database standards module.
---

# Database Standards

## Overview
This document defines database schema design principles, naming conventions, migration requirements, query optimization rules, and indexing strategies.

## Purpose
To maintain schema integrity, optimize query latency, and ensure database reliability at scale.

## When to Use
- When creating new tables, schemas, indexes, or relationships.
- When writing database migration scripts.
- When optimizing slow SQL queries.

## When NOT to Use
- Do NOT use this document to design API payloads (use `api-standards`).
- Do NOT use this document to outline CI/CD deployment logic (use `deployment`).

## Principles
1. **Schema as Code**: All database schema changes must be versioned, reviewed, and deployed via migration scripts.
2. **Data Integrity**: Enforce constraints (foreign keys, uniqueness, check constraints, non-nullability) at the database tier.
3. **Performance First**: Design schemas with execution paths and query patterns in mind.
4. **Backward Compatibility**: Migrations must allow the application to run smoothly during rolling updates.

## Workflow
*Note: This is a standard, not a workflow. See `database-design` workflow for execution steps.*

## Rules
- Table and column names MUST use snake_case (e.g., `user_accounts`, `created_at`).
- Foreign key columns MUST follow the format `target_table_singular_id` (e.g., `user_id`).
- You MUST NOT use raw SQL migrations that cannot be rolled back; every migration should have an up and down step (or be fully deterministic and safe).
- Table modifications that lock large datasets (e.g., adding a column with a default value to a table with millions of rows) MUST be executed using non-blocking patterns.
- Indexes MUST be created on all columns used in JOIN clauses, WHERE filters, or ORDER BY clauses that have high cardinality.

## Best Practices
- Use UUIDs (v4 or ordered v7) for primary keys instead of auto-incrementing integers for distributed or public-facing resources.
- Avoid using `SELECT *` in production queries; request only the specific columns needed.
- Write query plans (`EXPLAIN ANALYZE`) to verify index utilization before shipping new queries.

## Common Mistakes
- Storing JSON blobs in relational databases to bypass schema design, preventing indexing and query optimization.
- Missing foreign key indexes, leading to full table scans during joins and deletes.
- Executing queries inside application loops (N+1 query problem).

## Anti-patterns
- **The Shared DB**: Allowing multiple applications to directly read/write from the same database tables (creates tight architectural coupling).
- **The Index Avalanche**: Indexing every single column in a table, causing write operations to slow down.

## Examples
*Example: schema design migration snippet.*
```sql
-- Up Migration
CREATE TABLE articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content TEXT,
    author_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_articles_author_id ON articles(author_id);
```

## Completion Checklist
- [ ] Tables, columns, and indexes follow snake_case naming conventions.
- [ ] Migration scripts contain corresponding up/down steps or safe idempotent instructions.
- [ ] Index coverage exists for all query filters and joins.
- [ ] Execution plans (`EXPLAIN`) have been verified for complex queries.
- [ ] Database changes are backward compatible with the currently deployed application.
