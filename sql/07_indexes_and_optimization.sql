-- ============================================================================
-- Script Name: 07_indexes_and_optimization.sql
-- Description: Database Indexing, EXPLAIN QUERY PLAN, & Performance Optimization
-- Author: Data Analyst Intern
-- Target DBMS: SQLite 3
-- Task: Task 3 - SQL for Data Analysis
-- ============================================================================

-- ----------------------------------------------------------------------------
-- THEORY: WHY AND WHEN DO INDEXES IMPROVE PERFORMANCE?
-- ----------------------------------------------------------------------------
-- What is an Index?
-- An index is a specialized data structure (typically a B-Tree) that acts like
-- a book's index. Instead of scanning every single page (Full Table Scan - O(N)),
-- the database engine navigates directly to the matching pointer in O(log N) time.
--
-- When to create Indexes:
-- 1. Foreign key columns that are frequently joined (e.g., customer_id, product_id).
-- 2. Columns frequently used in WHERE filters (e.g., category, order_date, status).
-- 3. Columns frequently used in ORDER BY or GROUP BY clauses.
-- 4. Tables with high row counts (millions of rows).
--
-- Potential Drawbacks / Disadvantages of Over-Indexing:
-- 1. Slower Write Operations: Every INSERT, UPDATE, and DELETE must also update 
--    the corresponding B-Tree index structures, causing write performance degradation.
-- 2. Increased Disk Storage: Indexes consume additional physical disk and cache memory.
-- 3. Redundant Overhead: On very small tables, table scans can actually be faster 
--    than reading an index plus accessing the table page.
-- ----------------------------------------------------------------------------

-- Drop indexes if already created to show clean before/after comparisons
DROP INDEX IF EXISTS idx_orders_customer_id;
DROP INDEX IF EXISTS idx_orders_order_date;
DROP INDEX IF EXISTS idx_products_category;
DROP INDEX IF EXISTS idx_order_items_product_id;
DROP INDEX IF EXISTS idx_order_items_order_id;

-- ----------------------------------------------------------------------------
-- 1. BENCHMARK BEFORE INDEX CREATION (EXPLAIN QUERY PLAN)
-- ----------------------------------------------------------------------------

-- Observation: Notice that SQLite performs a full 'SCAN' on tables.
EXPLAIN QUERY PLAN
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE customer_id = 7;

EXPLAIN QUERY PLAN
SELECT product_id, product_name, price
FROM products
WHERE category = 'Electronics';

EXPLAIN QUERY PLAN
SELECT o.order_id, o.order_date, oi.product_id, oi.quantity
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = 3;

-- ----------------------------------------------------------------------------
-- 2. CREATE INDEXES ON STRATEGIC COLUMNS
-- ----------------------------------------------------------------------------

-- 2.1 Index on foreign key customer_id in orders (accelerates customer joins & lookups)
CREATE INDEX idx_orders_customer_id 
ON orders(customer_id);

-- 2.2 Index on order_date (accelerates time-series range queries and date sorting)
CREATE INDEX idx_orders_order_date 
ON orders(order_date);

-- 2.3 Index on category in products (accelerates category filtering and grouping)
CREATE INDEX idx_products_category 
ON products(category);

-- 2.4 Index on product_id in order_items (accelerates item-to-product joins)
CREATE INDEX idx_order_items_product_id 
ON order_items(product_id);

-- 2.5 Index on order_id in order_items (accelerates order header-to-item joins)
CREATE INDEX idx_order_items_order_id 
ON order_items(order_id);

-- ----------------------------------------------------------------------------
-- 3. BENCHMARK AFTER INDEX CREATION (EXPLAIN QUERY PLAN)
-- ----------------------------------------------------------------------------

-- Observation: Now SQLite uses 'SEARCH ... USING INDEX' instead of 'SCAN'!
EXPLAIN QUERY PLAN
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE customer_id = 7;

EXPLAIN QUERY PLAN
SELECT product_id, product_name, price
FROM products
WHERE category = 'Electronics';

EXPLAIN QUERY PLAN
SELECT o.order_id, o.order_date, oi.product_id, oi.quantity
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = 3;

-- ----------------------------------------------------------------------------
-- 4. QUERY OPTIMIZATION BEST PRACTICES & COMPARISONS
-- ----------------------------------------------------------------------------

-- Best Practice 1: Avoid SELECT *; Select Only Necessary Columns
-- BAD: SELECT * FROM orders JOIN order_items ON orders.order_id = order_items.order_id;
-- GOOD:
SELECT o.order_id, o.order_date, oi.quantity, oi.unit_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_date >= '2024-06-01';

-- Best Practice 2: Filter Early in the Query Pipeline
-- Apply WHERE conditions before grouping and joining to minimize intermediate result sets
SELECT 
    p.category,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed' -- Filter out non-completed orders early
GROUP BY p.category;

-- Best Practice 3: Prefer JOIN over correlated subqueries for bulk lookups
-- A JOIN allows the database planner to choose the most efficient join algorithm,
-- whereas correlated subqueries execute repeatedly for each outer row.
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Best Practice 4: Use UNION ALL instead of UNION when uniqueness is already guaranteed
-- UNION performs a costly sorting and deduplication step; UNION ALL avoids this overhead.
SELECT customer_name, 'Buyer' AS user_type FROM customers WHERE customer_id <= 10
UNION ALL
SELECT customer_name, 'Prospect' AS user_type FROM customers WHERE customer_id > 10;
