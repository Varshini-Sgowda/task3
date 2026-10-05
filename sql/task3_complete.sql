-- ============================================================================
-- Script Name: task3_complete.sql
-- Project: Task 3 - SQL for Data Analysis (Data Analyst Internship)
-- Author: Data Analyst Intern
-- DBMS: SQLite 3
-- Description: Master SQL script encompassing database schema setup, sample data
--              insertion, basic queries, aggregations, joins, subqueries, views,
--              indexes, query optimization, and business analytical reporting.
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ============================================================================
-- SECTION 1: DATABASE SCHEMA SETUP (DDL)
-- ============================================================================

DROP VIEW IF EXISTS customer_revenue_view;
DROP VIEW IF EXISTS product_sales_view;
DROP VIEW IF EXISTS category_revenue_view;
DROP VIEW IF EXISTS order_summary_view;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1.1 Customers Table
CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL,
    email         TEXT NOT NULL UNIQUE,
    city          TEXT,              -- Nullable for NULL handling demonstrations
    country       TEXT,              -- Nullable for NULL handling demonstrations
    signup_date   TEXT NOT NULL      -- ISO-8601 format: YYYY-MM-DD
);

-- 1.2 Products Table
CREATE TABLE products (
    product_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name   TEXT NOT NULL,
    category       TEXT NOT NULL,
    price          REAL NOT NULL CHECK(price > 0),
    stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0)
);

-- 1.3 Orders Table
CREATE TABLE orders (
    order_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id  INTEGER NOT NULL,
    order_date   TEXT NOT NULL,
    order_status TEXT NOT NULL CHECK(order_status IN ('Completed', 'Shipped', 'Processing', 'Cancelled', 'Pending')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- 1.4 Order Items Table
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id      INTEGER NOT NULL,
    product_id    INTEGER NOT NULL,
    quantity      INTEGER NOT NULL CHECK(quantity > 0),
    unit_price    REAL NOT NULL CHECK(unit_price > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- ============================================================================
-- SECTION 2: SAMPLE DATA INSERTION (DML)
-- ============================================================================

-- 2.1 Customers (18 total: 15 active buyers, 3 inactive prospects, 2 with NULLs)
INSERT INTO customers (customer_id, customer_name, email, city, country, signup_date) VALUES
(1,  'Aarav Sharma',     'aarav.sharma@example.com',    'Mumbai',        'India',         '2023-01-15'),
(2,  'Diya Patel',        'diya.patel@example.com',      'Ahmedabad',     'India',         '2023-02-10'),
(3,  'John Smith',        'john.smith@example.com',      'New York',      'United States', '2023-02-28'),
(4,  'Emily Johnson',     'emily.johnson@example.com',   'Chicago',       'United States', '2023-03-12'),
(5,  'Carlos Mendoza',    'carlos.m@example.com',        'Madrid',        'Spain',         '2023-03-25'),
(6,  'Sophia Dubois',     'sophia.d@example.com',        'Paris',         'France',        '2023-04-05'),
(7,  'Rohan Verma',       'rohan.verma@example.com',     'Bengaluru',     'India',         '2023-04-18'),
(8,  'Liam O''Connor',    'liam.oc@example.com',         'Dublin',        'Ireland',       '2023-05-02'),
(9,  'Mia Tanaka',        'mia.tanaka@example.com',      'Tokyo',         'Japan',         '2023-05-20'),
(10, 'Lucas Silva',       'lucas.silva@example.com',     'Sao Paulo',     'Brazil',        '2023-06-11'),
(11, 'Ananya Sen',        'ananya.sen@example.com',      'Kolkata',       'India',         '2023-06-29'),
(12, 'Noah Mueller',      'noah.m@example.com',          'Berlin',        'Germany',       '2023-07-14'),
(13, 'Fatima Al-Mansoor', 'fatima.m@example.com',        'Dubai',         'UAE',           '2023-08-01'),
(14, 'Chloe Lefevre',     'chloe.l@example.com',         NULL,            'France',        '2023-08-19'),
(15, 'David Kim',         'david.kim@example.com',       'Seoul',         NULL,            '2023-09-05'),
(16, 'Elena Rossi',       'elena.rossi@example.com',     'Rome',          'Italy',         '2023-10-12'),
(17, 'Vikram Malhotra',   'vikram.m@example.com',        'Delhi',         'India',         '2023-11-03'),
(18, 'Grace Taylor',      'grace.t@example.com',         'London',        'United Kingdom','2023-12-01');

-- 2.2 Products (22 total across 6 categories; 2 products unpurchased)
INSERT INTO products (product_id, product_name, category, price, stock_quantity) VALUES
(1,  'Smartphone Pro Max',           'Electronics',    899.99, 45),
(2,  'Noise-Cancelling Headphones',  'Electronics',    199.99, 80),
(3,  '4K Ultra HD Monitor',          'Electronics',    349.99, 25),
(4,  'Wireless Mechanical Keyboard', 'Electronics',     89.99, 60),
(5,  'Ergonomic Gaming Mouse',       'Electronics',     49.99, 110),
(6,  'USB-C Multi-Port Adapter',     'Electronics',     29.99, 150),
(7,  'Classic Cotton Crewneck T-Shirt', 'Clothing',     24.99, 200),
(8,  'Slim Fit Denim Jeans',            'Clothing',     59.99, 90),
(9,  'Waterproof Rain Jacket',          'Clothing',    119.99, 40),
(10, 'Running Athletic Shoes',          'Clothing',     84.99, 65),
(11, 'Merino Wool Beanie Hat',          'Clothing',     19.99, 120),
(12, 'Stainless Steel Cookware Set',  'Home & Kitchen', 149.99, 35),
(13, 'Espresso Coffee Machine',        'Home & Kitchen', 229.99, 18),
(14, 'Ceramic Dinnerware Set 16pc',    'Home & Kitchen',  69.99, 50),
(15, 'Cordless Stick Vacuum Cleaner',  'Home & Kitchen', 189.99, 22),
(16, 'Python for Data Analysis',       'Books',           44.99, 130),
(17, 'SQL Essentials & Optimization',  'Books',           39.99, 140),
(18, 'Deep Learning Illustrated',      'Books',           54.99, 75),
(19, 'Hydrating Daily Moisturizer',    'Beauty',          28.99, 85),
(20, 'Organic Vitamin C Glow Serum',   'Beauty',          32.99, 95),
(21, 'Premium Non-Slip Yoga Mat',      'Sports',          34.99, 70),
(22, 'Adjustable Dumbbell Set 50lbs',  'Sports',         179.99, 15);

-- 2.3 Orders (32 orders)
INSERT INTO orders (order_id, customer_id, order_date, order_status) VALUES
(101, 1,  '2024-01-10', 'Completed'),
(102, 2,  '2024-01-15', 'Completed'),
(103, 3,  '2024-01-22', 'Completed'),
(104, 4,  '2024-02-05', 'Completed'),
(105, 5,  '2024-02-14', 'Cancelled'),
(106, 1,  '2024-02-20', 'Completed'),
(107, 7,  '2024-03-01', 'Completed'),
(108, 8,  '2024-03-15', 'Completed'),
(109, 9,  '2024-03-28', 'Completed'),
(110, 10, '2024-04-04', 'Completed'),
(111, 2,  '2024-04-12', 'Completed'),
(112, 11, '2024-04-25', 'Completed'),
(113, 12, '2024-05-03', 'Completed'),
(114, 13, '2024-05-18', 'Completed'),
(115, 3,  '2024-05-29', 'Completed'),
(116, 14, '2024-06-08', 'Completed'),
(117, 15, '2024-06-19', 'Cancelled'),
(118, 7,  '2024-06-25', 'Completed'),
(119, 4,  '2024-07-02', 'Completed'),
(120, 6,  '2024-07-11', 'Completed'),
(121, 1,  '2024-07-20', 'Completed'),
(122, 5,  '2024-08-05', 'Completed'),
(123, 8,  '2024-08-14', 'Completed'),
(124, 10, '2024-08-22', 'Completed'),
(125, 2,  '2024-09-01', 'Shipped'),
(126, 9,  '2024-09-08', 'Shipped'),
(127, 11, '2024-09-15', 'Shipped'),
(128, 12, '2024-09-22', 'Shipped'),
(129, 3,  '2024-09-29', 'Shipped'),
(130, 13, '2024-10-01', 'Processing'),
(131, 7,  '2024-10-03', 'Processing'),
(132, 14, '2024-10-04', 'Pending');

-- 2.4 Order Items (56 records)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1,  101, 1,  1, 899.99),
(2,  101, 4,  1,  89.99),
(3,  102, 2,  1, 199.99),
(4,  102, 7,  2,  24.99),
(5,  103, 3,  1, 349.99),
(6,  103, 5,  2,  49.99),
(7,  104, 12, 1, 149.99),
(8,  104, 14, 1,  69.99),
(9,  105, 8,  1,  59.99),
(10, 106, 13, 1, 229.99),
(11, 106, 17, 2,  39.99),
(12, 107, 1,  1, 899.99),
(13, 107, 6,  2,  29.99),
(14, 108, 9,  1, 119.99),
(15, 108, 10, 1,  84.99),
(16, 109, 15, 1, 189.99),
(17, 109, 20, 2,  32.99),
(18, 110, 2,  1, 199.99),
(19, 110, 16, 1,  44.99),
(20, 111, 19, 2,  28.99),
(21, 111, 20, 1,  32.99),
(22, 112, 16, 2,  44.99),
(23, 112, 17, 1,  39.99),
(24, 112, 18, 1,  54.99),
(25, 113, 3,  1, 349.99),
(26, 113, 4,  1,  89.99),
(27, 114, 1,  1, 899.99),
(28, 115, 13, 1, 229.99),
(29, 115, 15, 1, 189.99),
(30, 116, 7,  3,  24.99),
(31, 116, 8,  1,  59.99),
(32, 117, 10, 1,  84.99),
(33, 118, 2,  1, 199.99),
(34, 118, 5,  1,  49.99),
(35, 119, 9,  1, 119.99),
(36, 119, 11, 2,  19.99),
(37, 120, 12, 1, 149.99),
(38, 120, 14, 1,  69.99),
(39, 120, 19, 1,  28.99),
(40, 121, 15, 1, 189.99),
(41, 122, 16, 1,  44.99),
(42, 122, 17, 1,  39.99),
(43, 123, 1,  1, 899.99),
(44, 124, 7,  2,  24.99),
(45, 124, 11, 1,  19.99),
(46, 125, 4,  1,  89.99),
(47, 125, 6,  1,  29.99),
(48, 126, 8,  1,  59.99),
(49, 126, 10, 1,  84.99),
(50, 127, 19, 2,  28.99),
(51, 128, 5,  2,  49.99),
(52, 129, 2,  1, 199.99),
(53, 130, 14, 2,  69.99),
(54, 131, 18, 2,  54.99),
(55, 132, 6,  2,  29.99),
(56, 132, 11, 1,  19.99);

-- ============================================================================
-- SECTION 3: BASIC QUERIES & FILTERING
-- ============================================================================

-- 3.1 All products
SELECT * FROM products;

-- 3.2 Specific columns & filter
SELECT product_id, product_name, category, price 
FROM products 
WHERE category = 'Electronics' AND price > 100.00;

-- 3.3 Status filtering with IN
SELECT order_id, customer_id, order_date, order_status 
FROM orders 
WHERE order_status IN ('Completed', 'Shipped');

-- 3.4 Handling NULLs with COALESCE
SELECT customer_id, customer_name, COALESCE(city, 'N/A') AS city, COALESCE(country, 'N/A') AS country 
FROM customers;

-- 3.5 Top 5 expensive products
SELECT product_id, product_name, category, price 
FROM products 
ORDER BY price DESC 
LIMIT 5;

-- ============================================================================
-- SECTION 4: AGGREGATE ANALYSIS & GROUP BY
-- ============================================================================

-- 4.1 Order status distribution
SELECT 
    order_status,
    COUNT(order_id) AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- 4.2 Revenue by category
SELECT 
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 4.3 High-spending customers using HAVING
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.customer_name
HAVING SUM(oi.quantity * oi.unit_price) > 500.00
ORDER BY total_spent DESC;

-- ============================================================================
-- SECTION 5: JOINS (INNER, LEFT, RIGHT EQUIVALENT, MULTI-TABLE)
-- ============================================================================

-- 5.1 INNER JOIN: Customers with orders
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date, o.order_status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- 5.2 LEFT JOIN: Include customers with 0 orders
SELECT c.customer_id, c.customer_name, o.order_id, o.order_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- 5.3 RIGHT JOIN Equivalent: Unpurchased products via reversed LEFT JOIN
SELECT p.product_id, p.product_name, p.category, oi.order_item_id
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- 5.4 Multi-table JOIN: Comprehensive line-item reporting
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    ROUND(oi.quantity * oi.unit_price, 2) AS line_total
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;

-- ============================================================================
-- SECTION 6: SUBQUERIES
-- ============================================================================

-- 6.1 Products priced above average price
SELECT product_id, product_name, price, ROUND((SELECT AVG(price) FROM products), 2) AS avg_price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 6.2 Customers who never placed an order
SELECT customer_id, customer_name, email
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);

-- 6.3 Average Revenue Per User (ARPU) via derived table
SELECT 
    COUNT(customer_id) AS paying_customers,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_user
FROM (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY o.customer_id
);

-- ============================================================================
-- SECTION 7: VIEWS CREATION & QUERYING
-- ============================================================================

CREATE VIEW customer_revenue_view AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.country,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price), 2), 0.00) AS total_revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.city, c.country;

CREATE VIEW product_sales_view AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price), 2), 0.00) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price;

CREATE VIEW category_revenue_view AS
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS total_products,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price), 2), 0.00) AS total_revenue,
    ROUND(AVG(p.price), 2) AS average_product_price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category;

-- Query the views
SELECT * FROM customer_revenue_view ORDER BY total_revenue DESC LIMIT 5;
SELECT * FROM product_sales_view ORDER BY total_revenue DESC LIMIT 5;
SELECT * FROM category_revenue_view ORDER BY total_revenue DESC;

-- ============================================================================
-- SECTION 8: INDEXING & QUERY OPTIMIZATION
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

-- Explain Query Plan demonstrating index usage
EXPLAIN QUERY PLAN
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE customer_id = 7;
