-- ============================================================================
-- Script Name: 04_joins.sql
-- Description: Table Joins (INNER, LEFT, RIGHT Equivalent, Multi-Table Joins)
-- Author: Data Analyst Intern
-- Target DBMS: SQLite 3
-- Task: Task 3 - SQL for Data Analysis
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. INNER JOIN
-- ----------------------------------------------------------------------------
-- Explanation:
-- An INNER JOIN returns only records where there is a match in BOTH tables.
-- Customers without any orders, and orders without valid customers, are excluded.

-- 1.1 Match customers with their placed orders
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date,
    o.order_status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date ASC;

-- ----------------------------------------------------------------------------
-- 2. LEFT JOIN (LEFT OUTER JOIN)
-- ----------------------------------------------------------------------------
-- Explanation:
-- A LEFT JOIN returns ALL records from the left table (customers), and matched 
-- records from the right table (orders). If no match exists, NULLs appear.
-- Useful for finding inactive customers who registered but never placed an order.

-- 2.1 View all customers and their orders (including inactive customers)
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.signup_date,
    o.order_id,
    o.order_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id ASC;

-- 2.2 Identify customers who have NEVER placed an order
-- Note: Checking 'WHERE o.order_id IS NULL' isolates the unmatched left rows.
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.signup_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- ----------------------------------------------------------------------------
-- 3. RIGHT JOIN EQUIVALENT IN SQLITE
-- ----------------------------------------------------------------------------
-- IMPORTANT CONCEPT EXPLANATION:
-- SQLite intentionally does NOT implement the 'RIGHT JOIN' syntax to keep the
-- database engine lightweight. 
-- However, mathematically:
--     TableA RIGHT JOIN TableB ON TableA.key = TableB.key
-- is 100% IDENTICAL to:
--     TableB LEFT JOIN TableA ON TableB.key = TableA.key
--
-- By reversing the position of the tables, any RIGHT JOIN is effortlessly 
-- executed as a LEFT JOIN with zero loss of functionality.

-- 3.1 Conceptual Demonstration:
-- Hypothetical Standard SQL (Not supported directly in SQLite syntax):
--     SELECT p.product_id, p.product_name, oi.quantity, oi.unit_price
--     FROM order_items oi
--     RIGHT JOIN products p ON oi.product_id = p.product_id;
--
-- Working SQLite Equivalent (Reversing tables to achieve RIGHT JOIN behavior):
-- Returns ALL products (even if they were never ordered) and matched order items.
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    oi.order_id,
    oi.quantity
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
ORDER BY p.product_id ASC;

-- 3.2 Finding unpurchased products using the reversed-table RIGHT JOIN equivalent:
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- ----------------------------------------------------------------------------
-- 4. MULTI-TABLE JOIN (COMPREHENSIVE ECOMMERCE ORDER DETAILS)
-- ----------------------------------------------------------------------------
-- Join Path:
-- customers (c) -> orders (o) -> order_items (oi) -> products (p)

SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    ROUND(oi.quantity * oi.unit_price, 2) AS line_item_revenue,
    o.order_status
FROM customers c
INNER JOIN orders o       ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p     ON oi.product_id = p.product_id
ORDER BY o.order_id ASC, oi.order_item_id ASC;

-- ----------------------------------------------------------------------------
-- 5. BONUS: FULL OUTER JOIN EQUIVALENT IN SQLITE
-- ----------------------------------------------------------------------------
-- In SQLite, a FULL OUTER JOIN is emulated by taking a LEFT JOIN, and UNIONing it
-- with the unmatched records from the right table.
SELECT 
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id

UNION

SELECT 
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

