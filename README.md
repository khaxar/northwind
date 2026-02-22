# Northwind SQL Analytics Project

## Overview

This repository contains a structured analytics project built on the classic **Northwind dataset**, a fictional company database representing sales, products, customers, employees, and related entities. It demonstrates a complete SQL workflow — from raw data loading to advanced analytics and insights — using **PostgreSQL and VS Code**.


## Database Schema

The project works with the following core Northwind tables:

- **Customers**
- **Suppliers**
- **Categories**
- **Employees**
- **Shippers**
- **Products**
- **Orders**
- **Order Details**

### Relationships

- `Orders.CustomerID → Customers.CustomerID`  
- `Orders.EmployeeID → Employees.EmployeeID`  
- `Orders.ShipVia → Shippers.ShipperID`  
- `OrderDetails.OrderID → Orders.OrderID`  
- `OrderDetails.ProductID → Products.ProductID`  
- `Products.SupplierID → Suppliers.SupplierID`  
- `Products.CategoryID → Categories.CategoryID`

## Project Description

This project covers a full SQL analytics workflow:

1. **Schema Creation and Data Loading**  
   - Tables are created in Postgres.  
   - CSV files are imported using SQL scripts.

2. **Exploration & Basic Queries**  
   - Initial data exploration and validation.  
   - Simple queries to understand structure and distributions.

3. **Analytical Modeling**  
   - Build a **fact table (`fact_orders`)** for analytics.
   - Build **dimension tables** for customers, products, and employees.

4. **Advanced Analytics**  
   - Revenue and performance analysis by time, category, customer, and employee.
   - Use of window functions, segmentation, and ranking.

5. **Business Impact KPIs**  
   - Insights into revenue trends, customer behavior, and product performance.
   - Cohort and retention analysis.

## How to Run

1. Install **PostgreSQL** locally.  
2. Open the project in **VS Code** with the PostgreSQL extension installed.  
3. Connect to your local Postgres database.  
4. Run the SQL scripts in order:

```bash
psql -d northwind -f sql/00_create_tables.sql
psql -d northwind -f sql/01_load_data.sql
psql -d northwind -f sql/02_explorations.sql
psql -d northwind -f sql/03_analysis_query.sql
psql -d northwind -f sql/04_advanced_analytics.sql
psql -d northwind -f sql/05_analytics_models.sql
psql -d northwind -f sql/06_kpi_analysis.sql
