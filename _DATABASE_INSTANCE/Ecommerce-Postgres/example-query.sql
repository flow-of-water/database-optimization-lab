-- ============================================
-- SQL ADVANCED EXAMPLES
-- Practice queries for db-lab
-- ============================================

-- ============================================
-- 1. WINDOW FUNCTIONS
-- ============================================

-- 1.1 Running total of inventory changes
SELECT 
    product_id,
    created_at,
    quantity_change,
    stock_after,
    SUM(quantity_change) OVER (
        PARTITION BY product_id 
        ORDER BY created_at
    ) AS running_total
FROM inventory_logs
WHERE product_id = 'p1111111-1111-1111-1111-111111111111'
ORDER BY created_at;

-- 1.2 Rank products by revenue
SELECT 
    p.name,
    SUM(oi.total_price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.total_price) DESC) AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY SUM(oi.total_price) DESC) AS dense_rank
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name;

-- 1.3 Compare each order to previous order (LAG/LEAD)
SELECT 
    id,
    user_id,
    total,
    created_at,
    LAG(total) OVER (PARTITION BY user_id ORDER BY created_at) AS prev_order_total,
    total - LAG(total) OVER (PARTITION BY user_id ORDER BY created_at) AS diff_from_prev,
    LEAD(total) OVER (PARTITION BY user_id ORDER BY created_at) AS next_order_total
FROM orders
WHERE status != 'cancelled'
ORDER BY user_id, created_at;

-- 1.4 Moving average (7-day sales)
SELECT 
    DATE(created_at) AS order_date,
    COUNT(*) AS daily_orders,
    SUM(total) AS daily_revenue,
    AVG(SUM(total)) OVER (
        ORDER BY DATE(created_at)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7d
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY DATE(created_at)
ORDER BY order_date;

-- 1.5 Percentile and distribution
SELECT 
    name,
    price,
    PERCENT_RANK() OVER (ORDER BY price) AS price_percentile,
    NTILE(4) OVER (ORDER BY price) AS price_quartile,
    CUME_DIST() OVER (ORDER BY price) AS cumulative_dist
FROM products
WHERE is_active = TRUE;

-- 1.6 First and last value in partition
SELECT DISTINCT
    category_id,
    FIRST_VALUE(name) OVER (
        PARTITION BY category_id 
        ORDER BY price DESC
    ) AS most_expensive,
    LAST_VALUE(name) OVER (
        PARTITION BY category_id 
        ORDER BY price DESC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS cheapest
FROM products;

-- ============================================
-- 2. RECURSIVE CTEs
-- ============================================

-- 2.1 Get full category tree
WITH RECURSIVE category_tree AS (
    -- Base case: root categories
    SELECT id, name, parent_id, 0 AS depth, name::TEXT AS full_path
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case
    SELECT c.id, c.name, c.parent_id, ct.depth + 1, 
           ct.full_path || ' > ' || c.name
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY full_path;

-- 2.2 Get all descendants of a category
WITH RECURSIVE descendants AS (
    SELECT id, name, parent_id
    FROM categories
    WHERE id = 1  -- Electronics
    
    UNION ALL
    
    SELECT c.id, c.name, c.parent_id
    FROM categories c
    JOIN descendants d ON c.parent_id = d.id
)
SELECT * FROM descendants;

-- 2.3 Get all ancestors (breadcrumb)
WITH RECURSIVE ancestors AS (
    SELECT id, name, parent_id, 1 AS level
    FROM categories
    WHERE id = 5  -- Smartphones
    
    UNION ALL
    
    SELECT c.id, c.name, c.parent_id, a.level + 1
    FROM categories c
    JOIN ancestors a ON c.id = a.parent_id
)
SELECT * FROM ancestors ORDER BY level DESC;

-- 2.4 Alternative: Using LTREE (PostgreSQL specific, much faster!)
-- Get all products in Electronics and subcategories
SELECT p.*
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE c.path <@ '1';  -- All descendants of category 1

-- Get ancestors using LTREE
SELECT * FROM categories 
WHERE path @> (SELECT path FROM categories WHERE id = 5);

-- ============================================
-- 3. JSONB OPERATIONS
-- ============================================

-- 3.1 Query JSONB fields
SELECT name, price, 
    attributes->>'color' AS color,
    attributes->>'storage' AS storage,
    (attributes->>'wattage')::int AS wattage
FROM products
WHERE attributes ? 'color';  -- Has 'color' key

-- 3.2 Filter by JSONB value
SELECT * FROM products
WHERE attributes @> '{"color": "black"}';

-- 3.3 Query nested JSONB
SELECT email, 
    preferences->'notifications'->>'email' AS email_notif,
    preferences->>'theme' AS theme
FROM users
WHERE preferences->'notifications'->>'email' = 'true';

-- 3.4 Update JSONB
UPDATE products
SET attributes = attributes || '{"warranty": "2 years"}'
WHERE category_id IN (SELECT id FROM categories WHERE path <@ '1');

-- 3.5 Remove key from JSONB
UPDATE products
SET attributes = attributes - 'warranty'
WHERE id = 'p1111111-1111-1111-1111-111111111111';

-- 3.6 Aggregate into JSONB
SELECT 
    o.id,
    jsonb_agg(
        jsonb_build_object(
            'product', oi.snapshot->>'name',
            'quantity', oi.quantity,
            'price', oi.total_price
        )
    ) AS items
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;

-- ============================================
-- 4. FULL-TEXT SEARCH
-- ============================================

-- 4.1 Basic search
SELECT name, description,
    ts_rank(search_vector, query) AS rank
FROM products,
    to_tsquery('english', 'phone | laptop') AS query
WHERE search_vector @@ query
ORDER BY rank DESC;

-- 4.2 Phrase search
SELECT name, description
FROM products
WHERE search_vector @@ phraseto_tsquery('english', 'gaming laptop');

-- 4.3 Highlight matches
SELECT 
    name,
    ts_headline('english', description, 
        to_tsquery('english', 'camera'), 
        'StartSel=<b>, StopSel=</b>'
    ) AS highlighted
FROM products
WHERE search_vector @@ to_tsquery('english', 'camera');

-- ============================================
-- 5. LATERAL JOINS
-- ============================================

-- 5.1 Top 3 products per category
SELECT c.name AS category, p.*
FROM categories c
CROSS JOIN LATERAL (
    SELECT id, name, price
    FROM products
    WHERE category_id = c.id
    ORDER BY price DESC
    LIMIT 3
) p;

-- 5.2 Latest order per user
SELECT u.full_name, o.*
FROM users u
CROSS JOIN LATERAL (
    SELECT id, order_number, total, created_at
    FROM orders
    WHERE user_id = u.id
    ORDER BY created_at DESC
    LIMIT 1
) o;

-- ============================================
-- 6. ADVANCED AGGREGATIONS
-- ============================================

-- 6.1 GROUPING SETS
SELECT 
    COALESCE(c.name, 'ALL CATEGORIES') AS category,
    COALESCE(p.name, 'ALL PRODUCTS') AS product,
    SUM(oi.total_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.id
JOIN categories c ON p.category_id = c.id
GROUP BY GROUPING SETS (
    (c.name, p.name),
    (c.name),
    ()
)
ORDER BY category NULLS LAST, product NULLS LAST;

-- 6.2 ROLLUP (hierarchical subtotals)
SELECT 
    DATE_TRUNC('month', o.created_at)::DATE AS month,
    o.status,
    COUNT(*) AS order_count,
    SUM(total) AS revenue
FROM orders o
GROUP BY ROLLUP (DATE_TRUNC('month', o.created_at), o.status)
ORDER BY month NULLS LAST, status NULLS LAST;

-- 6.3 CUBE (all combinations)
SELECT 
    c.name AS category,
    DATE_TRUNC('month', o.created_at)::DATE AS month,
    SUM(oi.total_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.id
JOIN categories c ON p.category_id = c.id
JOIN orders o ON oi.order_id = o.id
GROUP BY CUBE (c.name, DATE_TRUNC('month', o.created_at))
ORDER BY category NULLS LAST, month NULLS LAST;

-- 6.4 FILTER clause
SELECT 
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered,
    COUNT(*) FILTER (WHERE status = 'pending') AS pending,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled,
    SUM(total) FILTER (WHERE status = 'delivered') AS delivered_revenue
FROM orders;

-- ============================================
-- 7. PERFORMANCE & EXPLAIN
-- ============================================

-- 7.1 Basic EXPLAIN
EXPLAIN SELECT * FROM products WHERE price > 500;

-- 7.2 EXPLAIN ANALYZE (actually runs the query)
EXPLAIN ANALYZE SELECT * FROM products WHERE price > 500;

-- 7.3 With buffers and timing
EXPLAIN (ANALYZE, BUFFERS, TIMING) 
SELECT p.*, c.name AS category
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.price > 500;

-- 7.4 Compare index vs no index
-- First, drop index to compare
-- DROP INDEX idx_products_price;
EXPLAIN ANALYZE SELECT * FROM products WHERE price BETWEEN 100 AND 500;
-- CREATE INDEX idx_products_price ON products(price);

-- ============================================
-- 8. LOCKING & CONCURRENCY
-- ============================================

-- 8.1 SELECT FOR UPDATE (pessimistic locking)
BEGIN;
SELECT * FROM products 
WHERE id = 'p1111111-1111-1111-1111-111111111111'
FOR UPDATE;
-- Other transactions trying to update this row will wait
UPDATE products SET stock_quantity = stock_quantity - 1
WHERE id = 'p1111111-1111-1111-1111-111111111111';
COMMIT;

-- 8.2 SELECT FOR UPDATE SKIP LOCKED (queue processing)
BEGIN;
SELECT * FROM orders 
WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;
-- Process order...
COMMIT;

-- 8.3 Advisory locks (application-level)
SELECT pg_advisory_lock(123);  -- Acquire lock
-- Do something...
SELECT pg_advisory_unlock(123);  -- Release lock

-- ============================================
-- 9. USEFUL PATTERNS
-- ============================================

-- 9.1 Upsert (INSERT ... ON CONFLICT)
INSERT INTO cart_items (user_id, product_id, quantity)
VALUES ('b2222222-2222-2222-2222-222222222222', 'p1111111-1111-1111-1111-111111111111', 2)
ON CONFLICT (user_id, product_id) 
DO UPDATE SET quantity = cart_items.quantity + EXCLUDED.quantity;

-- 9.2 Returning clause
UPDATE products 
SET stock_quantity = stock_quantity - 1
WHERE id = 'p1111111-1111-1111-1111-111111111111'
RETURNING id, name, stock_quantity;

-- 9.3 CTE with INSERT/UPDATE/DELETE
WITH moved_orders AS (
    DELETE FROM orders 
    WHERE status = 'cancelled' 
        AND created_at < NOW() - INTERVAL '30 days'
    RETURNING *
)
INSERT INTO archived_orders SELECT * FROM moved_orders;  -- requires archived_orders table

-- 9.4 Generate series for reporting
SELECT 
    d::DATE AS date,
    COALESCE(COUNT(o.id), 0) AS orders,
    COALESCE(SUM(o.total), 0) AS revenue
FROM generate_series(
    NOW() - INTERVAL '30 days',
    NOW(),
    INTERVAL '1 day'
) AS d
LEFT JOIN orders o ON DATE(o.created_at) = d::DATE 
    AND o.status NOT IN ('cancelled', 'refunded')
GROUP BY d::DATE
ORDER BY d::DATE;

-- 9.5 Pagination with keyset (cursor-based)
-- More efficient than OFFSET for large datasets
SELECT id, name, price, created_at
FROM products
WHERE (created_at, id) < ('2024-01-01', 'last-seen-id')
ORDER BY created_at DESC, id DESC
LIMIT 20;