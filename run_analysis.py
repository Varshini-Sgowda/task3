"""
Script: run_analysis.py
Description: Automated runner to execute and display Task 3 SQL queries and business KPIs.
DBMS: SQLite 3
Author: Data Analyst Intern
"""

import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'data', 'ecommerce.db')

def get_connection():
    if not os.path.exists(DB_PATH):
        raise FileNotFoundError(f"Database not found at {DB_PATH}. Please run 01_database_setup.sql first.")
    return sqlite3.connect(DB_PATH)

def run_query(title, sql):
    print("\n" + "=" * 80)
    print(f"  {title.upper()}")
    print("=" * 80)
    conn = get_connection()
    c = conn.cursor()
    c.execute(sql)
    headers = [desc[0] for desc in c.description]
    rows = c.fetchall()
    conn.close()

    # Calculate column widths
    col_widths = [len(h) for h in headers]
    for row in rows:
        for i, val in enumerate(row):
            col_widths[i] = max(col_widths[i], len(str(val) if val is not None else "NULL"))

    header_line = " | ".join(h.ljust(col_widths[i]) for i, h in enumerate(headers))
    sep_line = "-+-".join("-" * col_widths[i] for i in range(len(headers)))
    print(header_line)
    print(sep_line)
    for row in rows:
        print(" | ".join((str(val) if val is not None else "NULL").ljust(col_widths[i]) for i, val in enumerate(row)))
    print(f"\n({len(rows)} row{'s' if len(rows) != 1 else ''} returned)\n")

def main():
    print("=" * 80)
    print("   TASK 3: SQL FOR DATA ANALYSIS - ECOMMERCE DATABASE REPORT")
    print("=" * 80)

    # 1. Total Overview
    run_query(
        "1. Overall Dataset Metrics",
        """
        SELECT 
            (SELECT COUNT(*) FROM customers) AS total_customers,
            (SELECT COUNT(*) FROM products) AS total_products,
            (SELECT COUNT(*) FROM orders) AS total_orders,
            (SELECT COUNT(*) FROM order_items) AS total_order_items,
            ROUND((SELECT SUM(quantity * unit_price) FROM order_items 
                   JOIN orders ON order_items.order_id = orders.order_id 
                   WHERE orders.order_status != 'Cancelled'), 2) AS total_net_revenue;
        """
    )

    # 2. Revenue by Category
    run_query(
        "2. Revenue by Product Category",
        """
        SELECT 
            p.category,
            COUNT(DISTINCT oi.order_id) AS total_orders,
            SUM(oi.quantity) AS total_units_sold,
            ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
        FROM products p
        JOIN order_items oi ON p.product_id = oi.product_id
        GROUP BY p.category
        ORDER BY total_revenue DESC;
        """
    )

    # 3. Top 5 Products by Revenue
    run_query(
        "3. Top 5 Products by Revenue",
        """
        SELECT 
            p.product_id,
            p.product_name,
            p.category,
            SUM(oi.quantity) AS units_sold,
            ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
        FROM products p
        JOIN order_items oi ON p.product_id = oi.product_id
        GROUP BY p.product_id, p.product_name, p.category
        ORDER BY total_revenue DESC
        LIMIT 5;
        """
    )

    # 4. Top 5 High-Spending Customers
    run_query(
        "4. Top 5 Customers by Total Spending",
        """
        SELECT 
            c.customer_id,
            c.customer_name,
            c.city,
            COUNT(DISTINCT o.order_id) AS orders_count,
            ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent
        FROM customers c
        JOIN orders o ON c.customer_id = o.customer_id
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.order_status != 'Cancelled'
        GROUP BY c.customer_id, c.customer_name, c.city
        ORDER BY total_spent DESC
        LIMIT 5;
        """
    )

    # 5. Average Revenue Per User (ARPU) & Average Order Value (AOV)
    run_query(
        "5. Key Ecommerce Benchmarks (ARPU & AOV)",
        """
        SELECT 
            (SELECT COUNT(DISTINCT customer_id) FROM orders WHERE order_status != 'Cancelled') AS active_customers,
            ROUND((SELECT AVG(order_rev) FROM (
                SELECT SUM(quantity * unit_price) AS order_rev 
                FROM order_items oi 
                JOIN orders o ON oi.order_id = o.order_id 
                WHERE o.order_status != 'Cancelled' 
                GROUP BY o.order_id
            )), 2) AS average_order_value_aov,
            ROUND((SELECT AVG(cust_rev) FROM (
                SELECT SUM(quantity * unit_price) AS cust_rev 
                FROM order_items oi 
                JOIN orders o ON oi.order_id = o.order_id 
                WHERE o.order_status != 'Cancelled' 
                GROUP BY o.customer_id
            )), 2) AS average_revenue_per_user_arpu;
        """
    )

    # 6. Unordered Products (RIGHT JOIN Equivalent)
    run_query(
        "6. Unordered Products (Reversed LEFT JOIN)",
        """
        SELECT 
            p.product_id,
            p.product_name,
            p.category,
            p.price,
            p.stock_quantity
        FROM products p
        LEFT JOIN order_items oi ON p.product_id = oi.product_id
        WHERE oi.order_item_id IS NULL;
        """
    )

    # 7. Customer Revenue View Output
    run_query(
        "7. Querying customer_revenue_view (Top 5)",
        """
        SELECT customer_id, customer_name, city, country, total_orders, total_revenue
        FROM customer_revenue_view
        ORDER BY total_revenue DESC
        LIMIT 5;
        """
    )

    print("=" * 80)
    print("   ALL QUERIES EXECUTED SUCCESSFULLY!")
    print("=" * 80)

if __name__ == '__main__':
    main()
