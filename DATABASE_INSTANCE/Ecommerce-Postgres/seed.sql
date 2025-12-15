-- ============================================
-- SEED DATA FOR SQL LEARNING
-- Run after schema.sql
-- ============================================

-- Roles
INSERT INTO roles (name, description) VALUES
    ('admin', 'Full system access'),
    ('seller', 'Can manage products and orders'),
    ('customer', 'Regular customer');

-- Users (password = 'password123' hashed)
INSERT INTO users (id, email, password_hash, full_name, preferences, created_at) VALUES
    ('a1111111-1111-1111-1111-111111111111', 'admin@shop.com', '$2b$10$xxx', 'Admin User', 
     '{"theme": "dark", "notifications": {"email": true, "sms": false}}', NOW() - INTERVAL '1 year'),
    ('b2222222-2222-2222-2222-222222222222', 'john@email.com', '$2b$10$xxx', 'John Doe',
     '{"theme": "light", "language": "en"}', NOW() - INTERVAL '6 months'),
    ('c3333333-3333-3333-3333-333333333333', 'jane@email.com', '$2b$10$xxx', 'Jane Smith',
     '{"theme": "light", "newsletter": true}', NOW() - INTERVAL '3 months'),
    ('d4444444-4444-4444-4444-444444444444', 'bob@email.com', '$2b$10$xxx', 'Bob Wilson',
     '{}', NOW() - INTERVAL '2 months'),
    ('e5555555-5555-5555-5555-555555555555', 'alice@email.com', '$2b$10$xxx', 'Alice Brown',
     '{"theme": "dark"}', NOW() - INTERVAL '1 month');

-- User roles
INSERT INTO user_roles (user_id, role_id) VALUES
    ('a1111111-1111-1111-1111-111111111111', 1),  -- admin
    ('b2222222-2222-2222-2222-222222222222', 3),  -- customer
    ('c3333333-3333-3333-3333-333333333333', 3),
    ('d4444444-4444-4444-4444-444444444444', 3),
    ('e5555555-5555-5555-5555-555555555555', 2);  -- seller

-- Addresses
INSERT INTO addresses (user_id, label, street, city, state, country, postal_code, is_default) VALUES
    ('b2222222-2222-2222-2222-222222222222', 'home', '123 Main St', 'New York', 'NY', 'USA', '10001', TRUE),
    ('b2222222-2222-2222-2222-222222222222', 'office', '456 Work Ave', 'New York', 'NY', 'USA', '10002', FALSE),
    ('c3333333-3333-3333-3333-333333333333', 'home', '789 Oak Dr', 'Los Angeles', 'CA', 'USA', '90001', TRUE),
    ('d4444444-4444-4444-4444-444444444444', 'home', '321 Pine St', 'Chicago', 'IL', 'USA', '60601', TRUE);

-- Categories (hierarchical)
INSERT INTO categories (id, parent_id, name, slug) VALUES
    (1, NULL, 'Electronics', 'electronics'),
    (2, 1, 'Phones', 'phones'),
    (3, 1, 'Laptops', 'laptops'),
    (4, 1, 'Accessories', 'accessories'),
    (5, 2, 'Smartphones', 'smartphones'),
    (6, 2, 'Feature Phones', 'feature-phones'),
    (7, 3, 'Gaming Laptops', 'gaming-laptops'),
    (8, 3, 'Business Laptops', 'business-laptops'),
    (9, NULL, 'Clothing', 'clothing'),
    (10, 9, 'Men', 'men'),
    (11, 9, 'Women', 'women'),
    (12, 10, 'Shirts', 'mens-shirts'),
    (13, 10, 'Pants', 'mens-pants'),
    (14, NULL, 'Books', 'books'),
    (15, 14, 'Fiction', 'fiction'),
    (16, 14, 'Non-Fiction', 'non-fiction'),
    (17, 14, 'Technical', 'technical');

SELECT setval('categories_id_seq', 17);

-- Tags
INSERT INTO tags (name, color) VALUES
    ('bestseller', '#ff6b6b'),
    ('new', '#4ecdc4'),
    ('sale', '#ffe66d'),
    ('featured', '#95e1d3'),
    ('limited', '#f38181');

-- Products
INSERT INTO products (id, category_id, sku, name, description, price, cost, stock_quantity, attributes, created_at) VALUES
    -- Smartphones
    ('p1111111-1111-1111-1111-111111111111', 5, 'PHN-IP15-256', 'iPhone 15 Pro', 
     'Latest Apple smartphone with A17 chip', 1199.00, 800.00, 50,
     '{"color": "titanium", "storage": "256GB", "display": "6.1 inch"}', NOW() - INTERVAL '3 months'),
    ('p2222222-2222-2222-2222-222222222222', 5, 'PHN-S24-256', 'Samsung Galaxy S24', 
     'Samsung flagship with AI features', 999.00, 650.00, 75,
     '{"color": "black", "storage": "256GB", "display": "6.2 inch"}', NOW() - INTERVAL '2 months'),
    ('p3333333-3333-3333-3333-333333333333', 5, 'PHN-PX8-128', 'Google Pixel 8', 
     'Pure Android experience with best camera', 699.00, 450.00, 30,
     '{"color": "hazel", "storage": "128GB", "display": "6.2 inch"}', NOW() - INTERVAL '4 months'),
    
    -- Laptops
    ('p4444444-4444-4444-4444-444444444444', 7, 'LPT-ROG-16', 'ASUS ROG Strix', 
     'High-performance gaming laptop', 1899.00, 1400.00, 20,
     '{"cpu": "i9-13900H", "gpu": "RTX 4070", "ram": "32GB", "storage": "1TB SSD"}', NOW() - INTERVAL '2 months'),
    ('p5555555-5555-5555-5555-555555555555', 8, 'LPT-TPX1-14', 'ThinkPad X1 Carbon', 
     'Premium business ultrabook', 1599.00, 1100.00, 35,
     '{"cpu": "i7-1365U", "ram": "16GB", "storage": "512GB SSD", "weight": "1.12kg"}', NOW() - INTERVAL '5 months'),
    
    -- Accessories
    ('p6666666-6666-6666-6666-666666666666', 4, 'ACC-APP-PRO', 'AirPods Pro 2', 
     'Wireless earbuds with noise cancellation', 249.00, 150.00, 100,
     '{"type": "earbuds", "anc": true, "battery": "6h"}', NOW() - INTERVAL '6 months'),
    ('p7777777-7777-7777-7777-777777777777', 4, 'ACC-CHG-65W', 'Anker 65W Charger', 
     'Fast charging for all devices', 45.00, 20.00, 200,
     '{"wattage": 65, "ports": 2, "type": "GaN"}', NOW() - INTERVAL '4 months'),
    
    -- Clothing
    ('p8888888-8888-8888-8888-888888888888', 12, 'CLO-TSH-BLK-M', 'Classic Black T-Shirt', 
     'Premium cotton t-shirt', 29.99, 10.00, 150,
     '{"size": "M", "color": "black", "material": "100% cotton"}', NOW() - INTERVAL '3 months'),
    ('p9999999-9999-9999-9999-999999999999', 12, 'CLO-TSH-WHT-L', 'Classic White T-Shirt', 
     'Premium cotton t-shirt', 29.99, 10.00, 120,
     '{"size": "L", "color": "white", "material": "100% cotton"}', NOW() - INTERVAL '3 months'),
    
    -- Books
    ('pa111111-1111-1111-1111-111111111111', 17, 'BOK-PG-SQL', 'PostgreSQL 15 Internals', 
     'Deep dive into PostgreSQL architecture', 59.99, 25.00, 40,
     '{"pages": 650, "format": "paperback", "language": "English"}', NOW() - INTERVAL '2 months'),
    ('pb222222-2222-2222-2222-222222222222', 15, 'BOK-DUN-1', 'Dune', 
     'Classic sci-fi masterpiece', 18.99, 8.00, 80,
     '{"pages": 412, "format": "paperback", "author": "Frank Herbert"}', NOW() - INTERVAL '8 months');

-- Product Tags
INSERT INTO product_tags (product_id, tag_id) VALUES
    ('p1111111-1111-1111-1111-111111111111', 1),  -- iPhone: bestseller
    ('p1111111-1111-1111-1111-111111111111', 4),  -- iPhone: featured
    ('p2222222-2222-2222-2222-222222222222', 2),  -- Samsung: new
    ('p2222222-2222-2222-2222-222222222222', 1),  -- Samsung: bestseller
    ('p4444444-4444-4444-4444-444444444444', 4),  -- ROG: featured
    ('p6666666-6666-6666-6666-666666666666', 1),  -- AirPods: bestseller
    ('p7777777-7777-7777-7777-777777777777', 3),  -- Charger: sale
    ('pa111111-1111-1111-1111-111111111111', 2);  -- PG Book: new

-- Product Images
INSERT INTO product_images (product_id, url, sort_order, is_primary) VALUES
    ('p1111111-1111-1111-1111-111111111111', '/images/iphone15-1.jpg', 0, TRUE),
    ('p1111111-1111-1111-1111-111111111111', '/images/iphone15-2.jpg', 1, FALSE),
    ('p2222222-2222-2222-2222-222222222222', '/images/s24-1.jpg', 0, TRUE),
    ('p4444444-4444-4444-4444-444444444444', '/images/rog-1.jpg', 0, TRUE);

-- Orders (multiple statuses for testing)
INSERT INTO orders (id, user_id, shipping_address_id, status, subtotal, tax, shipping_fee, total, created_at, metadata) VALUES
    ('o1111111-1111-1111-1111-111111111111', 'b2222222-2222-2222-2222-222222222222', 
     (SELECT id FROM addresses WHERE user_id = 'b2222222-2222-2222-2222-222222222222' LIMIT 1),
     'delivered', 1199.00, 107.91, 0, 1306.91, NOW() - INTERVAL '2 months', '{"promo_code": "FIRST10"}'),
    ('o2222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222',
     (SELECT id FROM addresses WHERE user_id = 'b2222222-2222-2222-2222-222222222222' LIMIT 1),
     'delivered', 249.00, 22.41, 5.99, 277.40, NOW() - INTERVAL '1 month', '{}'),
    ('o3333333-3333-3333-3333-333333333333', 'c3333333-3333-3333-3333-333333333333',
     (SELECT id FROM addresses WHERE user_id = 'c3333333-3333-3333-3333-333333333333' LIMIT 1),
     'shipped', 1899.00, 170.91, 0, 2069.91, NOW() - INTERVAL '5 days', '{}'),
    ('o4444444-4444-4444-4444-444444444444', 'c3333333-3333-3333-3333-333333333333',
     (SELECT id FROM addresses WHERE user_id = 'c3333333-3333-3333-3333-333333333333' LIMIT 1),
     'processing', 59.98, 5.40, 3.99, 69.37, NOW() - INTERVAL '2 days', '{}'),
    ('o5555555-5555-5555-5555-555555555555', 'd4444444-4444-4444-4444-444444444444',
     (SELECT id FROM addresses WHERE user_id = 'd4444444-4444-4444-4444-444444444444' LIMIT 1),
     'pending', 999.00, 89.91, 0, 1088.91, NOW() - INTERVAL '1 day', '{}'),
    ('o6666666-6666-6666-6666-666666666666', 'b2222222-2222-2222-2222-222222222222',
     (SELECT id FROM addresses WHERE user_id = 'b2222222-2222-2222-2222-222222222222' LIMIT 1),
     'cancelled', 45.00, 4.05, 5.99, 55.04, NOW() - INTERVAL '3 weeks', '{"cancel_reason": "changed mind"}');

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price, snapshot) VALUES
    ('o1111111-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111', 1, 1199.00, 1199.00,
     '{"name": "iPhone 15 Pro", "sku": "PHN-IP15-256"}'),
    ('o2222222-2222-2222-2222-222222222222', 'p6666666-6666-6666-6666-666666666666', 1, 249.00, 249.00,
     '{"name": "AirPods Pro 2", "sku": "ACC-APP-PRO"}'),
    ('o3333333-3333-3333-3333-333333333333', 'p4444444-4444-4444-4444-444444444444', 1, 1899.00, 1899.00,
     '{"name": "ASUS ROG Strix", "sku": "LPT-ROG-16"}'),
    ('o4444444-4444-4444-4444-444444444444', 'p8888888-8888-8888-8888-888888888888', 2, 29.99, 59.98,
     '{"name": "Classic Black T-Shirt", "sku": "CLO-TSH-BLK-M"}'),
    ('o5555555-5555-5555-5555-555555555555', 'p2222222-2222-2222-2222-222222222222', 1, 999.00, 999.00,
     '{"name": "Samsung Galaxy S24", "sku": "PHN-S24-256"}'),
    ('o6666666-6666-6666-6666-666666666666', 'p7777777-7777-7777-7777-777777777777', 1, 45.00, 45.00,
     '{"name": "Anker 65W Charger", "sku": "ACC-CHG-65W"}');

-- Inventory Logs (for window functions practice)
INSERT INTO inventory_logs (product_id, quantity_change, reason, stock_after, created_at) VALUES
    -- iPhone inventory changes over time
    ('p1111111-1111-1111-1111-111111111111', 100, 'restock', 100, NOW() - INTERVAL '3 months'),
    ('p1111111-1111-1111-1111-111111111111', -5, 'sale', 95, NOW() - INTERVAL '2 months 15 days'),
    ('p1111111-1111-1111-1111-111111111111', -10, 'sale', 85, NOW() - INTERVAL '2 months'),
    ('p1111111-1111-1111-1111-111111111111', -8, 'sale', 77, NOW() - INTERVAL '1 month 15 days'),
    ('p1111111-1111-1111-1111-111111111111', 50, 'restock', 127, NOW() - INTERVAL '1 month'),
    ('p1111111-1111-1111-1111-111111111111', -15, 'sale', 112, NOW() - INTERVAL '15 days'),
    ('p1111111-1111-1111-1111-111111111111', -12, 'sale', 100, NOW() - INTERVAL '7 days'),
    ('p1111111-1111-1111-1111-111111111111', -1, 'sale', 99, NOW() - INTERVAL '2 days'),
    ('p1111111-1111-1111-1111-111111111111', 2, 'return', 101, NOW() - INTERVAL '1 day'),
    ('p1111111-1111-1111-1111-111111111111', -1, 'sale', 100, NOW()),
    
    -- Samsung inventory
    ('p2222222-2222-2222-2222-222222222222', 100, 'restock', 100, NOW() - INTERVAL '2 months'),
    ('p2222222-2222-2222-2222-222222222222', -20, 'sale', 80, NOW() - INTERVAL '1 month'),
    ('p2222222-2222-2222-2222-222222222222', -5, 'sale', 75, NOW() - INTERVAL '1 day'),
    
    -- AirPods inventory
    ('p6666666-6666-6666-6666-666666666666', 150, 'restock', 150, NOW() - INTERVAL '6 months'),
    ('p6666666-6666-6666-6666-666666666666', -30, 'sale', 120, NOW() - INTERVAL '3 months'),
    ('p6666666-6666-6666-6666-666666666666', -20, 'sale', 100, NOW() - INTERVAL '1 month');

-- Reviews
INSERT INTO reviews (user_id, product_id, rating, comment, is_verified_purchase, created_at) VALUES
    ('b2222222-2222-2222-2222-222222222222', 'p1111111-1111-1111-1111-111111111111', 5, 
     'Amazing phone! The camera is incredible.', TRUE, NOW() - INTERVAL '1 month'),
    ('c3333333-3333-3333-3333-333333333333', 'p1111111-1111-1111-1111-111111111111', 4, 
     'Great phone but expensive.', FALSE, NOW() - INTERVAL '2 weeks'),
    ('d4444444-4444-4444-4444-444444444444', 'p1111111-1111-1111-1111-111111111111', 5, 
     'Best iPhone ever!', FALSE, NOW() - INTERVAL '1 week'),
    ('b2222222-2222-2222-2222-222222222222', 'p6666666-6666-6666-6666-666666666666', 5, 
     'Perfect sound quality and ANC.', TRUE, NOW() - INTERVAL '3 weeks'),
    ('c3333333-3333-3333-3333-333333333333', 'p4444444-4444-4444-4444-444444444444', 5, 
     'Beast of a gaming laptop!', TRUE, NOW() - INTERVAL '3 days'),
    ('d4444444-4444-4444-4444-444444444444', 'p2222222-2222-2222-2222-222222222222', 4, 
     'Great Android phone with good AI features.', FALSE, NOW() - INTERVAL '5 days');

-- Cart Items
INSERT INTO cart_items (user_id, product_id, quantity) VALUES
    ('b2222222-2222-2222-2222-222222222222', 'pa111111-1111-1111-1111-111111111111', 1),
    ('c3333333-3333-3333-3333-333333333333', 'p7777777-7777-7777-7777-777777777777', 2),
    ('d4444444-4444-4444-4444-444444444444', 'p8888888-8888-8888-8888-888888888888', 3);

-- ============================================
-- GENERATE MORE DATA (for performance testing)
-- ============================================

-- Generate 100 more users
INSERT INTO users (email, password_hash, full_name, created_at)
SELECT 
    'user' || i || '@example.com',
    '$2b$10$xxx',
    'User ' || i,
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 100) AS i;

-- Generate 200 more orders
INSERT INTO orders (user_id, status, subtotal, tax, shipping_fee, total, created_at)
SELECT 
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    (ARRAY['pending', 'paid', 'processing', 'shipped', 'delivered'])[floor(random() * 5 + 1)],
    round((random() * 1000 + 50)::numeric, 2) AS subtotal,
    round((random() * 100)::numeric, 2) AS tax,
    round((random() * 20)::numeric, 2) AS shipping_fee,
    round((random() * 1200 + 50)::numeric, 2) AS total,
    NOW() - (random() * INTERVAL '180 days')
FROM generate_series(1, 200);

-- Add order items to generated orders
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price, snapshot)
SELECT 
    o.id,
    p.id,
    floor(random() * 3 + 1)::int,
    p.price,
    p.price * floor(random() * 3 + 1)::int,
    jsonb_build_object('name', p.name, 'sku', p.sku)
FROM orders o
CROSS JOIN LATERAL (
    SELECT id, name, sku, price FROM products ORDER BY random() LIMIT floor(random() * 3 + 1)::int
) p
WHERE o.id NOT IN (SELECT DISTINCT order_id FROM order_items)
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFY DATA
-- ============================================

DO $$
BEGIN
    RAISE NOTICE 'Users: %', (SELECT COUNT(*) FROM users);
    RAISE NOTICE 'Products: %', (SELECT COUNT(*) FROM products);
    RAISE NOTICE 'Categories: %', (SELECT COUNT(*) FROM categories);
    RAISE NOTICE 'Orders: %', (SELECT COUNT(*) FROM orders);
    RAISE NOTICE 'Order Items: %', (SELECT COUNT(*) FROM order_items);
    RAISE NOTICE 'Inventory Logs: %', (SELECT COUNT(*) FROM inventory_logs);
    RAISE NOTICE 'Reviews: %', (SELECT COUNT(*) FROM reviews);
END $$;