-- ============================================================================
-- Script Name: 05_subqueries.sql
-- Description: Subqueries (Scalar, Multi-Row, Correlated, Derived Tables)
-- Author: Data Analyst Intern
-- Target DBMS: SQLite 3
-- Task: Task 3 - SQL for Data Analysis
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SCALAR SUBQUERIES (Returns a single value)
-- ----------------------------------------------------------------------------

-- 1.1 Products priced strictly above the catalog average product price
-- The inner query computes the catalog-wide average price
SELECT 
    product_id,
    product_name,
    category,
    price,
    ROUND((SELECT AVG(price) FROM products), 2) AS catalog_avg_price,
    ROUND(price - (SELECT AVG(price) FROM products), 2) AS diff_from_avg
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 1.2 Customer with the highest single total spend across all orders
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.email
HAVING SUM(oi.quantity * oi.unit_price) = (
    -- Subquery returns the maximum customer total spend
    SELECT MAX(customer_total)
    FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS customer_total
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        GROUP BY o2.customer_id
    )
);

-- ----------------------------------------------------------------------------
-- 2. MULTI-ROW SUBQUERIES WITH IN / NOT IN
-- ----------------------------------------------------------------------------

-- 2.1 Products that have NEVER been ordered (Using NOT IN)
SELECT 
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id 
    FROM order_items
);

-- 2.2 Customers who have NEVER placed an order (Using NOT IN)
SELECT 
    customer_id,
    customer_name,
    email,
    signup_date
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id 
    FROM orders
);

-- 2.3 Customers who ordered from the 'Electronics' category (Using IN)
SELECT 
    customer_id,
    customer_name,
    email
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE p.category = 'Electronics'
);

-- ----------------------------------------------------------------------------
-- 3. CORRELATED SUBQUERIES & EXISTS / NOT EXISTS
-- ----------------------------------------------------------------------------
-- Explanation:
-- A correlated subquery references columns from the outer query and executes
-- once for every row evaluated by the outer query.

-- 3.1 Products that have never been ordered (Using NOT EXISTS)
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM order_items oi 
    WHERE oi.product_id = p.product_id
);

-- 3.2 Display each customer alongside their total placed orders (Subquery in SELECT)
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    (SELECT COUNT(*) 
     FROM orders o 
     WHERE o.customer_id = c.customer_id) AS total_orders
FROM customers c
ORDER BY total_orders DESC;

-- ----------------------------------------------------------------------------
-- 4. DERIVED TABLES & ADVANCED BUSINESS BENCHMARKING
-- ----------------------------------------------------------------------------

-- 4.1 Average Revenue Per User (ARPU) Calculation
-- Derived table aggregates revenue per customer and outer query calculates the average
SELECT 
    COUNT(customer_id)                         AS total_active_customers,
    ROUND(SUM(customer_revenue), 2)            AS total_revenue,
    ROUND(AVG(customer_revenue), 2)            AS average_revenue_per_user
FROM (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS customer_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('Cancelled')
    GROUP BY o.customer_id
);

-- 4.2 Customers whose total spending is strictly ABOVE the average customer spending
SELECT 
    spending_summary.customer_id,
    c.customer_name,
    c.city,
    ROUND(spending_summary.total_spent, 2) AS total_spent
FROM (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('Cancelled')
    GROUP BY o.customer_id
) spending_summary
JOIN customers c ON spending_summary.customer_id = c.customer_id
WHERE spending_summary.total_spent > (
    -- Average spending across all paying customers
    SELECT AVG(cust_spend)
    FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS cust_spend
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        WHERE o2.order_status NOT IN ('Cancelled')
        GROUP BY o2.customer_id
    )
)
ORDER BY spending_summary.total_spent DESC;

-- 4.3 Customers who placed MORE orders than the average customer order frequency
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS orders_placed
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) AS order_count
        FROM orders
        GROUP BY customer_id
    )
)
ORDER BY orders_placed DESC;
