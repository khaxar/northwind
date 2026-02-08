-- Preview tables
SELECT * FROM customers LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_details LIMIT 10;

-- Counts
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_products FROM products;

-- Orders with Customer names
SELECT o.OrderID, c.CompanyName, o.OrderDate
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
LIMIT 10;

-- Products with Category names
SELECT p.ProductName, c.CategoryName
FROM products p
JOIN categories c ON p.CategoryID = c.CategoryID
LIMIT 10;

-- Orders with Employee names and Shipper
SELECT o.OrderID, e.FirstName || ' ' || e.LastName AS EmployeeName, s.CompanyName AS ShipperName
FROM orders o
JOIN employees e ON o.EmployeeID = e.EmployeeID
JOIN shippers s ON o.ShipVia = s.ShipperID
LIMIT 10;

-- Top 10 customers by number of orders
SELECT c.CompanyName, COUNT(o.OrderID) AS total_orders
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY total_orders DESC
LIMIT 10;