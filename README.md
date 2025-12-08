# 🧪 DB-Lab

A personal laboratory for experimenting with database technologies, advanced SQL techniques, and performance optimization.

## 📌 Purpose

This repo serves as a sandbox to learn, test, and benchmark:

- Advanced SQL queries (Window Functions, CTEs, JSONB, Full-text Search)
- Indexing strategies and query optimization
- Database design patterns
- Performance benchmarking



## 📚 Topics Covered

| Topic | Status | Notes |
|-------|--------|-------|
| Window Functions | ✅ | ROW_NUMBER, RANK, LAG, LEAD, running totals |
| Recursive CTEs | ✅ | Tree traversal, hierarchical data |
| JSONB Operations | ✅ | Query, index, update JSON data |
| Full-text Search | ✅ | tsvector, tsquery, ranking |
| Advanced Indexing | ✅ | B-Tree, GIN, GiST, partial, expression |
| Query Optimization | 🔄 | EXPLAIN ANALYZE, index tuning |
| Partitioning | 📋 | Range, list, hash partitioning |
| Locking & Concurrency | ✅ | FOR UPDATE, advisory locks |
| Materialized Views | 📋 | Caching expensive queries |
| Stored Procedures | 📋 | PL/pgSQL functions |

✅ Done | 🔄 In Progress | 📋 Planned

## 🔧 Useful Commands

```sql
-- Check table sizes
SELECT relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Check index usage
SELECT indexrelname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Kill long-running queries
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE duration > interval '5 minutes';
```

## 📖 Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Use The Index, Luke](https://use-the-index-luke.com/)
- [PostgreSQL Exercises](https://pgexercises.com/)
- [Explain Visualizer](https://explain.dalibo.com/)