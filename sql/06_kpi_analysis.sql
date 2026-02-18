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
