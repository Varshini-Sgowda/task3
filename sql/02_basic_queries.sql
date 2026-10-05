-- ============================================================================
-- Script Name: 02_basic_queries.sql
-- Description: Basic SQL Data Retrieval, Filtering, and Sorting Techniques
-- Author: Data Analyst Intern
-- Target DBMS: SQLite 3
-- Task: Task 3 - SQL for Data Analysis
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. BASIC SELECT STATEMENTS
-- ----------------------------------------------------------------------------

-- 1.1 Retrieve all records and columns from the products table
-- Explanation: The asterisk (*) is a wildcard meaning "all columns".
SELECT * 
FROM products;

-- 1.2 Retrieve specific columns to optimize bandwidth and readability
-- Best Practice: Avoid SELECT * in production to minimize memory and I/O overhead.
SELECT product_id, product_name, category, price
FROM products;

-- 1.3 Retrieve distinct categories (eliminates duplicate entries)
SELECT DISTINCT category
FROM products;

-- ----------------------------------------------------------------------------
-- 2. FILTERING WITH THE WHERE CLAUSE
-- ----------------------------------------------------------------------------

-- 2.1 Single condition: Find all products in the 'Electronics' category
SELECT product_id, product_name, category, price
FROM products
WHERE category = 'Electronics';

-- 2.2 Numerical comparison: Find affordable products priced under $50.00
SELECT product_id, product_name, category, price
FROM products
WHERE price < 50.00;

-- 2.3 Multiple conditions with AND: Products in 'Clothing' category priced above $50.00
SELECT product_id, product_name, category, price
FROM products
WHERE category = 'Clothing' AND price > 50.00;

-- 2.4 Multiple conditions with OR: Orders that are either 'Cancelled' or 'Pending'
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE order_status = 'Cancelled' OR order_status = 'Pending';

-- 2.5 Using NOT: Retrieve all orders that are NOT cancelled
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE NOT order_status = 'Cancelled';

-- ----------------------------------------------------------------------------
-- 3. RANGE, SET, AND PATTERN FILTERING
-- ----------------------------------------------------------------------------

-- 3.1 Using BETWEEN: Find products priced between $50 and $200 (inclusive)
SELECT product_id, product_name, category, price
FROM products
WHERE price BETWEEN 50.00 AND 200.00;

-- 3.2 Using IN operator: Filter orders by a specific set of active statuses
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE order_status IN ('Processing', 'Shipped', 'Pending');

-- 3.3 Pattern matching with LIKE: Find products containing 'Wireless' in the name
-- '%' is a wildcard for zero, one, or multiple characters.
SELECT product_id, product_name, category, price
FROM products
WHERE product_name LIKE '%Wireless%';

-- ----------------------------------------------------------------------------
-- 4. NULL VALUE HANDLING
-- ----------------------------------------------------------------------------

-- 4.1 Identify records where a column is NULL (Missing city)
-- Note: Always use IS NULL rather than = NULL because NULL represents an unknown value.
SELECT customer_id, customer_name, email, city, country
FROM customers
WHERE city IS NULL;

-- 4.2 Identify records where a column is NOT NULL
SELECT customer_id, customer_name, email, city, country
FROM customers
WHERE city IS NOT NULL;

-- 4.3 Using COALESCE to replace NULL with a default placeholder value
-- COALESCE returns the first non-null argument in the list.
SELECT 
    customer_id,
    customer_name,
    COALESCE(city, 'Unknown City') AS resolved_city,
    COALESCE(country, 'Unknown Country') AS resolved_country
FROM customers;

-- ----------------------------------------------------------------------------
-- 5. SORTING AND PAGINATION (ORDER BY & LIMIT)
-- ----------------------------------------------------------------------------

-- 5.1 Sort products by price in ascending order (default: ASC)
SELECT product_id, product_name, category, price
FROM products
ORDER BY price ASC;

-- 5.2 Sort products by price in descending order (highest price first)
SELECT product_id, product_name, category, price
FROM products
ORDER BY price DESC;

-- 5.3 Multi-column sort: Order by category ascending, then price descending
SELECT product_id, product_name, category, price
FROM products
ORDER BY category ASC, price DESC;

-- 5.4 Using LIMIT: Get the top 5 most expensive products
SELECT product_id, product_name, category, price
FROM products
ORDER BY price DESC
LIMIT 5;

-- 5.5 Using LIMIT and OFFSET: Pagination (skip top 5, get next 5)
SELECT product_id, product_name, category, price
FROM products
ORDER BY price DESC
LIMIT 5 OFFSET 5;
