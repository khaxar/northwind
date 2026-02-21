-- Top 5 products by revenue per month

WITH monthly_product_sales AS (
    SELECT
        DATE_TRUNC('month', o.OrderDate) AS month,
        p.ProductName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS revenue
    FROM orders o
    JOIN order_details od ON o.OrderID = od.OrderID
    JOIN products p ON od.ProductID = p.ProductID
    GROUP BY month, p.ProductName
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank
    FROM monthly_product_sales
) ranked
WHERE rank <= 5
ORDER BY month, revenue DESC;


-- Top customers per region

SELECT
    c.Region,
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS total_spent,
    RANK() OVER (PARTITION BY c.Region ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS rank
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
JOIN order_details od ON o.OrderID = od.OrderID
GROUP BY c.Region, c.CompanyName
HAVING c.Region IS NOT NULL
ORDER BY c.Region, rank;


-- Average shipping delay per employee

DROP VIEW IF EXISTS fact_orders CASCADE;

ALTER TABLE orders
ALTER COLUMN ShippedDate TYPE DATE USING NULLIF(ShippedDate,NULL)::DATE;

SELECT
    e.FirstName || ' ' || e.LastName AS Employee,
    AVG(o.ShippedDate - o.OrderDate) AS avg_days_to_ship
FROM employees e
JOIN orders o ON e.EmployeeID = o.EmployeeID
WHERE o.ShippedDate IS NOT NULL
GROUP BY e.EmployeeID
ORDER BY avg_days_to_ship;


-- Customer retention: repeat orders

SELECT
    c.CompanyName,
    COUNT(DISTINCT o.OrderID) AS total_orders,
    COUNT(DISTINCT DATE_TRUNC('year', o.OrderDate)) AS years_active
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName
HAVING COUNT(DISTINCT o.OrderID) > 1
ORDER BY years_active DESC, total_orders DESC;


-- Rank customers by total revenue

SELECT
    c.CustomerID,
    c.CompanyName,
    SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) AS total_revenue,
    RANK() OVER (ORDER BY SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) DESC) AS revenue_rank
FROM fact_orders f
JOIN dim_customers c ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY revenue_rank
LIMIT 20;


-- Top 10% customers by number of orders

SELECT
    CustomerID,
    COUNT(OrderID) AS num_orders,
    NTILE(10) OVER (ORDER BY COUNT(OrderID) DESC) AS decile_rank
FROM fact_orders
GROUP BY CustomerID
ORDER BY decile_rank, num_orders DESC;


-- Employee performance by revenue and orders handled

SELECT
    e.EmployeeID,
    e.employee,
    SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) AS total_revenue,
    COUNT(DISTINCT f.OrderID) AS total_orders,
    RANK() OVER (ORDER BY SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) DESC) AS revenue_rank
FROM fact_orders f
JOIN dim_employees e ON f.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.employee
ORDER BY revenue_rank;


-- Revenue vs Discount Impact by Product

SELECT
    p.ProductID,
    p.ProductName,
    SUM(f.Quantity * f.UnitPrice) AS gross_revenue,
    SUM(f.Quantity * f.UnitPrice * f.Discount) AS total_discount,
    SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) AS net_revenue,
    ROUND(
        SUM(f.Quantity * f.UnitPrice * f.Discount) 
        / NULLIF(SUM(f.Quantity * f.UnitPrice), 0) * 100,
        2
    ) AS discount_percentage
FROM fact_orders f
JOIN dim_products p ON f.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY discount_percentage DESC;

-- High Revenue, Low Repeat Customers

WITH customer_stats AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT OrderID) AS total_orders,
        SUM(Quantity * UnitPrice * (1 - Discount)) AS total_revenue
    FROM fact_orders
    GROUP BY CustomerID
)
SELECT *
FROM customer_stats
WHERE total_orders = 1
ORDER BY total_revenue DESC
LIMIT 20;

-- Employee Efficiency Score

SELECT
    e.EmployeeID,
    e.employee,
    COUNT(DISTINCT f.OrderID) AS total_orders,
    SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) AS total_revenue,
    ROUND(
        SUM(f.Quantity * f.UnitPrice * (1 - f.Discount)) 
        / NULLIF(COUNT(DISTINCT f.OrderID), 0),
        2
    ) AS revenue_per_order
FROM fact_orders f
JOIN dim_employees e ON f.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.employee
ORDER BY revenue_per_order DESC;
