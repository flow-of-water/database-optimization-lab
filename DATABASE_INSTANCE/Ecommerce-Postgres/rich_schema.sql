\i base_schema.sql

-- ============================================
-- INDEXES
-- ============================================

-- B-Tree indexes (default, for equality and range)
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_inventory_logs_product ON inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_created ON inventory_logs(created_at DESC);
CREATE INDEX idx_reviews_product ON reviews(product_id);

-- Learn: Partial index (only index what matters)
CREATE INDEX idx_products_active ON products(id) WHERE is_active = TRUE;
CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';

-- Learn: Expression index
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
CREATE INDEX idx_products_name_lower ON products(LOWER(name));

-- Learn: JSONB indexing
CREATE INDEX idx_products_attributes ON products USING GIN(attributes);
CREATE INDEX idx_users_preferences ON users USING GIN(preferences);

-- Learn: Full-text search index
CREATE INDEX idx_products_search ON products USING GIN(search_vector);

-- Learn: Trigram index for LIKE/ILIKE
CREATE INDEX idx_products_name_trgm ON products USING GIN(name gin_trgm_ops);

-- Learn: LTREE index for hierarchical queries
CREATE INDEX idx_categories_path ON categories USING GIST(path);

-- Learn: Composite index (order matters!)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number = 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                       LPAD(NEXTVAL('order_number_seq')::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1;

CREATE TRIGGER trg_orders_number
    BEFORE INSERT ON orders
    FOR EACH ROW
    WHEN (NEW.order_number IS NULL)
    EXECUTE FUNCTION generate_order_number();

-- Track order status changes
CREATE OR REPLACE FUNCTION track_order_status()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO order_status_history (order_id, old_status, new_status)
        VALUES (NEW.id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_status_history
    AFTER UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION track_order_status();

-- Auto-update product search vector
CREATE OR REPLACE FUNCTION update_product_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector = 
        setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.sku, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products_search_vector
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_product_search_vector();

-- Update category path (materialized path pattern)
CREATE OR REPLACE FUNCTION update_category_path()
RETURNS TRIGGER AS $$
DECLARE
    parent_path LTREE;
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.path = NEW.id::TEXT::LTREE;
        NEW.level = 0;
    ELSE
        SELECT path, level + 1 INTO parent_path, NEW.level
        FROM categories WHERE id = NEW.parent_id;
        NEW.path = parent_path || NEW.id::TEXT::LTREE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_categories_path
    BEFORE INSERT OR UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_category_path();

-- ============================================
-- VIEWS (for common queries)
-- ============================================

-- Product with category info
CREATE VIEW v_products_full AS
SELECT 
    p.*,
    c.name AS category_name,
    c.path AS category_path,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.id) AS review_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, c.id;

-- Order summary
CREATE VIEW v_order_summary AS
SELECT 
    o.*,
    u.email AS user_email,
    u.full_name AS user_name,
    COUNT(oi.id) AS item_count,
    SUM(oi.quantity) AS total_quantity
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.id;

-- ============================================
-- USEFUL COMMENTS FOR LEARNING
-- ============================================

COMMENT ON TABLE categories IS 'Hierarchical categories using LTREE for efficient tree queries';
COMMENT ON COLUMN products.attributes IS 'JSONB for flexible product attributes - use GIN index';
COMMENT ON COLUMN products.search_vector IS 'Full-text search vector - auto-updated by trigger';
COMMENT ON TABLE inventory_logs IS 'Audit log for inventory changes - good for window functions practice';
COMMENT ON TABLE order_status_history IS 'Order audit trail - auto-populated by trigger';