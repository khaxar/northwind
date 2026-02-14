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