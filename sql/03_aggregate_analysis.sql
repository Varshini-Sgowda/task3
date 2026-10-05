-- ============================================================================
-- Script Name: 03_aggregate_analysis.sql
-- Description: Aggregate Functions, Grouping, and Summarization Techniques
-- Author: Data Analyst Intern
-- Target DBMS: SQLite 3
-- Task: Task 3 - SQL for Data Analysis
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. OVERALL SUMMARY METRICS (AGGREGATE FUNCTIONS)
-- ----------------------------------------------------------------------------

-- 1.1 Total customers, total registered cities, and total distinct countries
SELECT 
    COUNT(customer_id)           AS total_customers,
    COUNT(city)                  AS customers_with_city,   -- Excludes NULLs
    COUNT(DISTINCT country)      AS unique_countries
FROM customers;

-- 1.2 Total orders and order volume overview
SELECT 
    COUNT(*)                     AS total_orders,
    MIN(order_date)              AS earliest_order_date,
    MAX(order_date)              AS latest_order_date
FROM orders;

-- 1.3 Product pricing summary statistics (MIN, MAX, AVG, SUM of inventory value)
SELECT 
    COUNT(product_id)                           AS total_products,
    ROUND(MIN(price), 2)                        AS minimum_price,
    ROUND(MAX(price), 2)                        AS maximum_price,
    ROUND(AVG(price), 2)                        AS average_price,
    ROUND(SUM(price * stock_quantity), 2)       AS total_inventory_valuation
FROM products;

-- 1.4 Total global sales revenue across all completed/valid order items
SELECT 
    COUNT(order_item_id)                        AS total_items_sold,
    SUM(quantity)                               AS total_units_sold,
    ROUND(SUM(quantity * unit_price), 2)        AS total_gross_revenue,
    ROUND(AVG(quantity * unit_price), 2)        AS average_order_item_value
FROM order_items;

-- ----------------------------------------------------------------------------
-- 2. GROUP BY ANALYSIS (BUSINESS BREAKDOWNS)
-- ----------------------------------------------------------------------------

-- 2.1 Order count distribution by order status
SELECT 
    order_status,
    COUNT(order_id)                             AS order_count,
    ROUND(COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_total
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- 2.2 Product catalog distribution and average price per category
SELECT 
    category,
    COUNT(product_id)                           AS product_count,
    ROUND(MIN(price), 2)                        AS min_price,
    ROUND(MAX(price), 2)                        AS max_price,
    ROUND(AVG(price), 2)                        AS avg_price,
    SUM(stock_quantity)                         AS total_stock_on_hand
FROM products
GROUP BY category
ORDER BY avg_price DESC;

-- 2.3 Total sales revenue by product category
SELECT 
    p.category,
    COUNT(DISTINCT oi.order_id)                 AS distinct_orders,
    SUM(oi.quantity)                            AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS category_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 2.4 Top 5 best-selling products by total revenue
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity)                            AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- 3. FILTERING AGGREGATES WITH HAVING
-- ----------------------------------------------------------------------------
-- Key Concept:
-- WHERE filters individual rows BEFORE they are grouped.
-- HAVING filters aggregated groups AFTER GROUP BY calculations are performed.

-- 3.1 High-performing categories with total revenue exceeding $1,000.00
SELECT 
    p.category,
    SUM(oi.quantity)                            AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 1000.00
ORDER BY total_revenue DESC;

-- 3.2 High-spending customers who have spent more than $500.00 in total
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id)                  AS completed_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)  AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Cancelled')       -- WHERE filters out cancelled orders first
GROUP BY c.customer_id, c.customer_name
HAVING SUM(oi.quantity * oi.unit_price) > 500.00-- HAVING filters customers with > $500 spent
ORDER BY total_spent DESC;

-- 3.3 Frequent buyers: Customers who placed 2 or more orders
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id)                           AS total_orders_placed
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2
ORDER BY total_orders_placed DESC, c.customer_name ASC;

