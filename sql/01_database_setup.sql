-- ============================================================================
-- Script Name: 01_database_setup.sql
-- Description: DDL & DML - Database Schema Setup & Sample Data Insertion
-- Author: Data Analyst Intern
-- Target DBMS: SQLite 3
-- Task: Task 3 - SQL for Data Analysis
-- ============================================================================

-- Enable foreign key constraint enforcement in SQLite
PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- 1. DROP EXISTING TABLES (Reverse Dependency Order)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- ----------------------------------------------------------------------------
-- 2. CREATE TABLES WITH CONSTRAINTS
-- ----------------------------------------------------------------------------

-- Table: customers
-- Description: Stores customer profile and registration information.
-- Demonstrates: PRIMARY KEY, UNIQUE, NOT NULL, and nullable columns for NULL handling.
CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL,
    email         TEXT NOT NULL UNIQUE,
    city          TEXT,              -- Nullable to demonstrate NULL value handling
    country       TEXT,              -- Nullable to demonstrate NULL value handling
    signup_date   TEXT NOT NULL      -- Stored in ISO-8601 format: YYYY-MM-DD
);

-- Table: products
-- Description: Stores product catalog, categories, pricing, and current inventory.
-- Demonstrates: CHECK constraints for positive price and non-negative stock.
CREATE TABLE products (
    product_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name   TEXT NOT NULL,
    category       TEXT NOT NULL,
    price          REAL NOT NULL CHECK(price > 0),
    stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0)
);

-- Table: orders
-- Description: Stores order headers linked to customers.
-- Demonstrates: FOREIGN KEY with customer reference, CHECK constraint on statuses.
CREATE TABLE orders (
    order_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id  INTEGER NOT NULL,
    order_date   TEXT NOT NULL,      -- Stored in ISO-8601 format: YYYY-MM-DD
    order_status TEXT NOT NULL CHECK(order_status IN ('Completed', 'Shipped', 'Processing', 'Cancelled', 'Pending')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Table: order_items
-- Description: Stores line items for each order connecting orders to products.
-- Demonstrates: Multi-table relational modeling, quantity/price integrity.
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id      INTEGER NOT NULL,
    product_id    INTEGER NOT NULL,
    quantity      INTEGER NOT NULL CHECK(quantity > 0),
    unit_price    REAL NOT NULL CHECK(unit_price > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 3. INSERT SAMPLE DATA
-- ----------------------------------------------------------------------------

-- 3.1 Insert Customers (18 Customers: 15 active buyers, 3 inactive for LEFT JOIN demos, 2 with NULL values)
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
(14, 'Chloe Lefevre',     'chloe.l@example.com',         NULL,            'France',        '2023-08-19'), -- City is NULL
(15, 'David Kim',         'david.kim@example.com',       'Seoul',         NULL,            '2023-09-05'), -- Country is NULL
(16, 'Elena Rossi',       'elena.rossi@example.com',     'Rome',          'Italy',         '2023-10-12'), -- Inactive (0 orders)
(17, 'Vikram Malhotra',   'vikram.m@example.com',        'Delhi',         'India',         '2023-11-03'), -- Inactive (0 orders)
(18, 'Grace Taylor',      'grace.t@example.com',         'London',        'United Kingdom','2023-12-01'); -- Inactive (0 orders)

-- 3.2 Insert Products (22 Products across 6 Categories; Products 21 & 22 have 0 orders)
INSERT INTO products (product_id, product_name, category, price, stock_quantity) VALUES
-- Electronics
(1,  'Smartphone Pro Max',           'Electronics',    899.99, 45),
(2,  'Noise-Cancelling Headphones',  'Electronics',    199.99, 80),
(3,  '4K Ultra HD Monitor',          'Electronics',    349.99, 25),
(4,  'Wireless Mechanical Keyboard', 'Electronics',     89.99, 60),
(5,  'Ergonomic Gaming Mouse',       'Electronics',     49.99, 110),
(6,  'USB-C Multi-Port Adapter',     'Electronics',     29.99, 150),
-- Clothing
(7,  'Classic Cotton Crewneck T-Shirt', 'Clothing',     24.99, 200),
(8,  'Slim Fit Denim Jeans',            'Clothing',     59.99, 90),
(9,  'Waterproof Rain Jacket',          'Clothing',    119.99, 40),
(10, 'Running Athletic Shoes',          'Clothing',     84.99, 65),
(11, 'Merino Wool Beanie Hat',          'Clothing',     19.99, 120),
-- Home & Kitchen
(12, 'Stainless Steel Cookware Set',  'Home & Kitchen', 149.99, 35),
(13, 'Espresso Coffee Machine',        'Home & Kitchen', 229.99, 18),
(14, 'Ceramic Dinnerware Set 16pc',    'Home & Kitchen',  69.99, 50),
(15, 'Cordless Stick Vacuum Cleaner',  'Home & Kitchen', 189.99, 22),
-- Books
(16, 'Python for Data Analysis',       'Books',           44.99, 130),
(17, 'SQL Essentials & Optimization',  'Books',           39.99, 140),
(18, 'Deep Learning Illustrated',      'Books',           54.99, 75),
-- Beauty
(19, 'Hydrating Daily Moisturizer',    'Beauty',          28.99, 85),
(20, 'Organic Vitamin C Glow Serum',   'Beauty',          32.99, 95),
-- Sports (Products 21 & 22 will have NO orders to demonstrate unpurchased products)
(21, 'Premium Non-Slip Yoga Mat',      'Sports',          34.99, 70),
(22, 'Adjustable Dumbbell Set 50lbs',  'Sports',         179.99, 15);

-- 3.3 Insert Orders (32 Orders: Dates from Jan 2024 to Oct 2024; Mixed statuses)
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

-- 3.4 Insert Order Items (56 Order Items across 32 Orders)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
-- Order 101 (Customer 1 - Aarav)
(1,  101, 1,  1, 899.99),
(2,  101, 4,  1,  89.99),
-- Order 102 (Customer 2 - Diya)
(3,  102, 2,  1, 199.99),
(4,  102, 7,  2,  24.99),
-- Order 103 (Customer 3 - John)
(5,  103, 3,  1, 349.99),
(6,  103, 5,  2,  49.99),
-- Order 104 (Customer 4 - Emily)
(7,  104, 12, 1, 149.99),
(8,  104, 14, 1,  69.99),
-- Order 105 (Customer 5 - Carlos - Cancelled)
(9,  105, 8,  1,  59.99),
-- Order 106 (Customer 1 - Aarav)
(10, 106, 13, 1, 229.99),
(11, 106, 17, 2,  39.99),
-- Order 107 (Customer 7 - Rohan)
(12, 107, 1,  1, 899.99),
(13, 107, 6,  2,  29.99),
-- Order 108 (Customer 8 - Liam)
(14, 108, 9,  1, 119.99),
(15, 108, 10, 1,  84.99),
-- Order 109 (Customer 9 - Mia)
(16, 109, 15, 1, 189.99),
(17, 109, 20, 2,  32.99),
-- Order 110 (Customer 10 - Lucas)
(18, 110, 2,  1, 199.99),
(19, 110, 16, 1,  44.99),
-- Order 111 (Customer 2 - Diya)
(20, 111, 19, 2,  28.99),
(21, 111, 20, 1,  32.99),
-- Order 112 (Customer 11 - Ananya)
(22, 112, 16, 2,  44.99),
(23, 112, 17, 1,  39.99),
(24, 112, 18, 1,  54.99),
-- Order 113 (Customer 12 - Noah)
(25, 113, 3,  1, 349.99),
(26, 113, 4,  1,  89.99),
-- Order 114 (Customer 13 - Fatima)
(27, 114, 1,  1, 899.99),
-- Order 115 (Customer 3 - John)
(28, 115, 13, 1, 229.99),
(29, 115, 15, 1, 189.99),
-- Order 116 (Customer 14 - Chloe)
(30, 116, 7,  3,  24.99),
(31, 116, 8,  1,  59.99),
-- Order 117 (Customer 15 - David - Cancelled)
(32, 117, 10, 1,  84.99),
-- Order 118 (Customer 7 - Rohan)
(33, 118, 2,  1, 199.99),
(34, 118, 5,  1,  49.99),
-- Order 119 (Customer 4 - Emily)
(35, 119, 9,  1, 119.99),
(36, 119, 11, 2,  19.99),
-- Order 120 (Customer 6 - Sophia)
(37, 120, 12, 1, 149.99),
(38, 120, 14, 1,  69.99),
(39, 120, 19, 1,  28.99),
-- Order 121 (Customer 1 - Aarav)
(40, 121, 15, 1, 189.99),
-- Order 122 (Customer 5 - Carlos)
(41, 122, 16, 1,  44.99),
(42, 122, 17, 1,  39.99),
-- Order 123 (Customer 8 - Liam)
(43, 123, 1,  1, 899.99),
-- Order 124 (Customer 10 - Lucas)
(44, 124, 7,  2,  24.99),
(45, 124, 11, 1,  19.99),
-- Order 125 (Customer 2 - Diya - Shipped)
(46, 125, 4,  1,  89.99),
(47, 125, 6,  1,  29.99),
-- Order 126 (Customer 9 - Mia - Shipped)
(48, 126, 8,  1,  59.99),
(49, 126, 10, 1,  84.99),
-- Order 127 (Customer 11 - Ananya - Shipped)
(50, 127, 19, 2,  28.99),
-- Order 128 (Customer 12 - Noah - Shipped)
(51, 128, 5,  2,  49.99),
-- Order 129 (Customer 3 - John - Shipped)
(52, 129, 2,  1, 199.99),
-- Order 130 (Customer 13 - Fatima - Processing)
(53, 130, 14, 2,  69.99),
-- Order 131 (Customer 7 - Rohan - Processing)
(54, 131, 18, 2,  54.99),
-- Order 132 (Customer 14 - Chloe - Pending)
(55, 132, 6,  2,  29.99),
(56, 132, 11, 1,  19.99);

