
-- Order fact

CREATE VIEW fact_orders AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    o.CustomerID,
    o.EmployeeID,
    o.ShipVia,
    od.ProductID,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    (od.UnitPrice * od.Quantity * (1 - od.Discount)) AS revenue
FROM orders o
JOIN order_details od ON o.OrderID = od.OrderID;


-- Customer dimension

CREATE VIEW dim_customers AS
SELECT
    CustomerID,
    CompanyName,
    ContactName,
    City,
    Country,
    Region
FROM customers;

-- Product dimension

CREATE VIEW dim_products AS
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    s.CompanyName AS Supplier,
    p.UnitPrice
FROM products p
JOIN categories c ON p.CategoryID = c.CategoryID
JOIN suppliers s ON p.SupplierID = s.SupplierID;

-- Employee dimension

CREATE VIEW dim_employees AS
SELECT
    EmployeeID,
    FirstName || ' ' || LastName AS employee,
    Title,
    City,
    Country
FROM employees;


-- Revenue by month

SELECT
    DATE_TRUNC('month', OrderDate) AS month,
    SUM(revenue) AS total_revenue
FROM fact_orders
GROUP BY 1
ORDER BY 1;


-- Revenue by category

SELECT
    d.CategoryName,
    SUM(f.revenue) AS revenue
FROM fact_orders f
JOIN dim_products d ON f.ProductID = d.ProductID
GROUP BY d.CategoryName
ORDER BY revenue DESC;


-- Revenue by country

SELECT
    c.Country,
    SUM(f.revenue) AS revenue
FROM fact_orders f
JOIN dim_customers c ON f.CustomerID = c.CustomerID
GROUP BY c.Country
ORDER BY revenue DESC;


-- Monthly revenue materialized view

CREATE MATERIALIZED VIEW mv_monthly_revenue AS
SELECT
    DATE_TRUNC('month', OrderDate) AS month,
    SUM(revenue) AS total_revenue
FROM fact_orders
GROUP BY 1;

REFRESH MATERIALIZED VIEW mv_monthly_revenue;