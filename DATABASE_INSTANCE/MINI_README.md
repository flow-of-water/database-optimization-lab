# E-Commerce Database

Sample database schema designed for practicing advanced SQL techniques.

## Quick Start

```bash
createdb ecommerce_postgres
psql ecommerce_postgres < schema.sql
psql ecommerce_postgres < seed.sql
```

## Schema Overview

![Schema](./../_public/database_instance/Screenshot%20from%202025-12-08%2021-39-50.png)


## Files

| File | Description |
|------|-------------|
| `schema.sql` | Tables, indexes, triggers, functions |
| `seed.sql` | Sample data (~105 users, ~200 orders) |
| `example-query.sql` | 50+ practice queries |

## Practice Topics

- **Window Functions**: `inventory_logs` table
- **Recursive CTEs**: `categories` tree
- **JSONB**: `products.attributes`, `users.preferences`
- **Full-text Search**: `products.search_vector`
- **LTREE**: `categories.path`

## Extensions Required

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "ltree";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```