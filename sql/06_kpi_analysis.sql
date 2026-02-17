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