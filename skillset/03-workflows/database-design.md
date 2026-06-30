# Database Design Workflow

## Purpose
To design normalized, efficient, indexed, and maintainable database schemas.

## When to Use
- Before adding new tables, altering columns, or creating data relationships.

## Required Prerequisite Skills
- `database-standards` (to apply naming and integrity rules)
- `architecture-thinking` (to evaluate scale and relationship patterns)

## Expected Inputs
- Domain models and entity definitions.
- Expected data volume, write-to-read ratios, and query patterns.

## Execution Workflow
1. **Define Entities & Relationships**: Identify database tables, fields, types, and primary/foreign keys.
2. **Apply Database Standards**: Ensure tables and columns use snake_case. Use UUIDs for public primary keys.
3. **Plan Indexes**: Analyze query patterns. Create indexes on column filters (`WHERE`), ordering (`ORDER BY`), and join columns.
4. **Draft Migration Code**: Write safe, backward-compatible SQL migration files (including rollback steps if applicable).
5. **Test Query Performance**: Apply `architecture-thinking` to evaluate query complexity. Write an `EXPLAIN` query plan mockup.
6. **Review Schema**: Verify that tables are correctly normalized and check constraints are in place.

## Expected Outputs
- Database schema migration files.
- Index documentation.
- Query plan verification (`EXPLAIN` outputs).

## Completion Checklist
- [ ] Schema diagrams or field definitions are documented.
- [ ] Naming conventions comply with database standards (snake_case).
- [ ] Indexes are defined for all foreign keys and filter columns.
- [ ] Migrations are designed to be backward compatible.
- [ ] Query optimization plans have been reviewed and approved.
