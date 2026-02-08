# Northwind

## Folder Structure
- data/          : CSV files
- sql/           : SQL scripts (table creation + queries)
- notebooks/     : Optional notebooks
- README.md      : Project overview

## Tables Imported
- Customers
- Suppliers
- Categories
- Employees
- Shippers
- Products
- Orders
- Order Details

## Relationships
- Orders.CustomerID → Customers.CustomerID
- Orders.EmployeeID → Employees.EmployeeID
- Orders.ShipVia → Shippers.ShipperID
- OrderDetails.OrderID → Orders.OrderID
- OrderDetails.ProductID → Products.ProductID
- Products.SupplierID → Suppliers.SupplierID
- Products.CategoryID → Categories.CategoryID