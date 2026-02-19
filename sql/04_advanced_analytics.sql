-- Monthly revenue trend

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.OrderDate) AS month,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS revenue
    FROM orders o
    JOIN order_details od ON o.OrderID = od.OrderID
    GROUP BY 1
)
SELECT
    month,
    revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    ROUND(
        100 * (revenue - LAG(revenue) OVER (ORDER BY month)) 
        / LAG(revenue) OVER (ORDER BY month),
        2
    ) AS growth_pct
FROM monthly_sales
ORDER BY month;

-- Top customers with rank

SELECT
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS total_spent,
    RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS rank
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
JOIN order_details od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName
ORDER BY rank
LIMIT 20;

-- Best product per category

WITH product_sales AS (
    SELECT
        c.CategoryName,
        p.ProductName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS total_sales
    FROM products p
    JOIN categories c ON p.CategoryID = c.CategoryID
    JOIN order_details od ON p.ProductID = od.ProductID
    GROUP BY c.CategoryName, p.ProductName
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY CategoryName ORDER BY total_sales DESC) AS rnk
    FROM product_sales
) ranked
WHERE rnk = 1
ORDER BY total_sales DESC;

-- Employee performance vs average

WITH employee_sales AS (
    SELECT
        e.EmployeeID,
        e.FirstName || ' ' || e.LastName AS employee,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS total_sales
    FROM employees e
    JOIN orders o ON e.EmployeeID = o.EmployeeID
    JOIN order_details od ON o.OrderID = od.OrderID
    GROUP BY e.EmployeeID
)
SELECT
    employee,
    total_sales,
    ROUND(
        total_sales - AVG(total_sales) OVER (),
        2
    ) AS diff_from_avg
FROM employee_sales
ORDER BY total_sales DESC;

-- Customer lifetime value (CLV)

SELECT
    c.CompanyName,
    MIN(o.OrderDate) AS first_order,
    MAX(o.OrderDate) AS last_order,
    COUNT(DISTINCT o.OrderID) AS total_orders,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS lifetime_value
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
JOIN order_details od ON o.OrderID = od.OrderID
GROUP BY c.CompanyName
ORDER BY lifetime_value DESC;


-- Materialized view: total revenue per month

CREATE MATERIALIZED VIEW mv_monthly_revenue AS
SELECT
    DATE_TRUNC('month', OrderDate) AS month,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue
FROM fact_orders
GROUP BY DATE_TRUNC('month', OrderDate)
ORDER BY month;

-- Materialized view: total revenue per customer

CREATE MATERIALIZED VIEW mv_customer_revenue AS
SELECT
    CustomerID,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue
FROM fact_orders
GROUP BY CustomerID
ORDER BY total_revenue DESC;

-- Materialized view: total revenue per product

CREATE MATERIALIZED VIEW mv_product_revenue AS
SELECT
    ProductID,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue
FROM fact_orders
GROUP BY ProductID
ORDER BY total_revenue DESC;

-- Refresh all materialized views immediately

REFRESH MATERIALIZED VIEW mv_monthly_revenue;
REFRESH MATERIALIZED VIEW mv_customer_revenue;
REFRESH MATERIALIZED VIEW mv_product_revenue;


-- Rank products by total revenue

SELECT
    p.ProductID,
    p.ProductName,
    SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) AS total_revenue,
    RANK() OVER (ORDER BY SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) DESC) AS revenue_rank
FROM fact_orders f
JOIN dim_products p ON f.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY revenue_rank
LIMIT 20;

-- Products with highest discount applied

SELECT
    p.ProductID,
    p.ProductName,
    SUM(f.Quantity * f.UnitPrice * f.Discount) AS total_discount_amount,
    RANK() OVER (ORDER BY SUM(f.Quantity * f.UnitPrice * f.Discount) DESC) AS discount_rank
FROM fact_orders f
JOIN dim_products p ON f.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY discount_rank
LIMIT 20;


-- Monthly revenue

SELECT
    DATE_TRUNC('month', OrderDate) AS month,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue
FROM fact_orders
GROUP BY month
ORDER BY month;

-- Moving Average (3-month) for Monthly Revenue

SELECT
    month,
    total_revenue,
    AVG(total_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_month
FROM (
    SELECT
        DATE_TRUNC('month', OrderDate) AS month,
        SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue
    FROM fact_orders
    GROUP BY month
) sub
ORDER BY month;

-- Quarterly Revenue Trend

SELECT
    DATE_TRUNC('quarter', OrderDate) AS quarter,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue
FROM fact_orders
GROUP BY quarter
ORDER BY quarter;

-- Peak Months by Revenue

SELECT
    DATE_TRUNC('month', OrderDate) AS month,
    SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue,
    RANK() OVER (ORDER BY SUM(Quantity * UnitPrice * (1 - Discount)) DESC) AS revenue_rank
FROM fact_orders
GROUP BY month
ORDER BY revenue_rank
LIMIT 5;


