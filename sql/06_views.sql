-- ============================================================================
-- Script Name: 06_views.sql
-- Description: Creating and Querying SQL Views for Analytical Reporting
-- Author: Data Analyst Intern
-- Target DBMS: SQLite 3
-- Task: Task 3 - SQL for Data Analysis
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONCEPT EXPLANATION: WHAT IS A VIEW?
-- ----------------------------------------------------------------------------
-- A SQL View is a virtual table based on the result-set of an SQL query.
-- Unlike regular tables, views do NOT store data physically on disk (unless 
-- materialized). Instead, the database engine executes the underlying query 
-- dynamically whenever the view is referenced.
--
-- Key Benefits:
-- 1. Query Simplification: Encapsulates complex joins and aggregations into 
--    reusable virtual tables.
-- 2. Security & Data Governance: Restricts direct access to sensitive raw tables.
-- 3. Consistency: Standardizes business metric definitions across all analysts.
-- ----------------------------------------------------------------------------

-- Drop views if they already exist
DROP VIEW IF EXISTS customer_revenue_view;
DROP VIEW IF EXISTS product_sales_view;
DROP VIEW IF EXISTS category_revenue_view;
DROP VIEW IF EXISTS order_summary_view;

-- ----------------------------------------------------------------------------
-- 1. CREATE VIEWS
-- ----------------------------------------------------------------------------

-- View 1: customer_revenue_view
-- Aggregates customer purchase history, total orders, and total monetary value.
CREATE VIEW customer_revenue_view AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.country,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price), 2), 0.00) AS total_revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status NOT IN ('Cancelled')
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.city, c.country;

-- View 2: product_sales_view
-- Summarizes sales performance and unit volume by product.
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

-- View 3: category_revenue_view
-- Macro-level view summarizing total revenue, total units, and average item price by category.
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

-- View 4 (Bonus): order_summary_view
-- Consolidated order-level details with customer name, total items, and invoice amount.
CREATE VIEW order_summary_view AS
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    c.country,
    o.order_status,
    COUNT(oi.order_item_id) AS item_count,
    SUM(oi.quantity) AS total_quantity,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, c.customer_name, c.country, o.order_status;

-- ----------------------------------------------------------------------------
-- 2. QUERYING THE VIEWS
-- ----------------------------------------------------------------------------

-- 2.1 Query customer_revenue_view: Top 5 VIP customers
SELECT customer_id, customer_name, total_orders, total_revenue
FROM customer_revenue_view
ORDER BY total_revenue DESC
LIMIT 5;

-- 2.2 Query product_sales_view: Products that generated the highest revenue
SELECT product_id, product_name, category, units_sold, total_revenue
FROM product_sales_view
ORDER BY total_revenue DESC
LIMIT 5;

-- 2.3 Query category_revenue_view: Revenue contribution ranked by category
SELECT category, total_products, total_units_sold, total_revenue, average_product_price
FROM category_revenue_view
ORDER BY total_revenue DESC;

-- 2.4 Query order_summary_view: High-value orders exceeding $500.00
SELECT order_id, order_date, customer_name, order_status, total_quantity, order_total
FROM order_summary_view
WHERE order_total > 500.00
ORDER BY order_total DESC;
