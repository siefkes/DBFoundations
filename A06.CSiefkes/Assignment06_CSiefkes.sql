--*************************************************************************--
-- Title: Assignment06
-- Author: CSiefkes
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2026-11-16,CSiefkes,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CSiefkes')
	 Begin 
	  Alter Database [Assignment06DB_CSiefkes] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CSiefkes;
	 End
	Create Database Assignment06DB_CSiefkes;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CSiefkes;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- --Select all columns from each table

-- SELECT CategoryID, CategoryName
-- FROM dbo.Categories

-- SELECT ProductID, ProductName, CategoryID, UnitPrice
-- FROM dbo.Products

-- SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
-- FROM dbo.Employees

-- SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count 
-- FROM dbo.Inventories

--Create the view with schemabinding

GO

CREATE VIEW vCategories
WITH SCHEMABINDING
AS
SELECT CategoryID, CategoryName
FROM dbo.Categories; 

GO

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products;

GO

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees;

GO

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count 
FROM dbo.Inventories;

GO

SELECT * FROM vCategories
SELECT * FROM vProducts
SELECT * FROM vEmployees
SELECT * FROM vInventories

GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

GO

DENY SELECT ON Categories TO PUBLIC
GRANT SELECT ON vCategories TO PUBLIC

GO 

DENY SELECT ON Products TO PUBLIC
GRANT SELECT ON vProducts TO PUBLIC

GO

DENY SELECT ON Employees TO PUBLIC
GRANT SELECT ON vEmployees TO PUBLIC

GO

DENY SELECT ON Inventories TO PUBLIC
GRANT SELECT ON vInventories TO PUBLIC

GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- --Identify the tables that will be pulled from

-- SELECT * FROM Categories
-- SELECT * FROM Products

-- -- Identify how these two tables will be joined

-- SELECT * FROM Categories JOIN Products
-- ON Categories.CategoryID = Products.CategoryID; 

-- -- Identify just the columns that you want shown from these two joined tables

-- SELECT CategoryName, ProductName, UnitPrice
-- FROM Categories JOIN Products
-- ON Categories.CategoryID = Products.CategoryID;

-- --Add in Order By
-- GO

-- SELECT CategoryName, ProductName, UnitPrice
-- FROM Categories JOIN Products
-- ON Categories.CategoryID = Products.CategoryID
-- ORDER BY CategoryName, ProductName; 

-- GO

--Create a view of the query created

GO

CREATE VIEW [dbo].[vProductsByCategories]
AS
SELECT TOP 10000 CategoryName, ProductName, UnitPrice
FROM Categories JOIN Products
ON Categories.CategoryID = Products.CategoryID
ORDER BY CategoryName, ProductName; 

GO

SELECT * FROM dbo.vProductsByCategories

GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- --Identify the tables needed

-- SELECT * FROM Products
-- SELECT * FROM Inventories

-- --Create the join between the 2 tables

-- GO

-- SELECT * FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID; 

-- GO
-- --Select the columns you need

-- GO

-- SELECT ProductName, InventoryDate, Count 
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- GO
-- --Add in Order By

-- GO

-- SELECT ProductName, InventoryDate, Count 
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID
-- ORDER BY ProductName, InventoryDate, Count 

-- GO

--Create a new view for this query

GO

CREATE VIEW [dbo].[vInventoriesByProductsByDates]
AS
SELECT TOP 10000 ProductName, InventoryDate, Count 
FROM Products JOIN Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY ProductName, InventoryDate, Count 

GO

SELECT * FROM [dbo].[vInventoriesByProductsByDates]

GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- --Identify the tables needs

-- SELECT * FROM Inventories
-- SELECT * FROM Employees

-- --Identify how to join the two tables

-- GO

-- SELECT * FROM Inventories JOIN Employees
-- ON Inventories.EmployeeID = Employees.EmployeeID;

-- GO

-- --Identify the columns specifically needs

-- GO

-- SELECT InventoryDate, EmployeeName = [EmployeeFirstName]+ '' + [EmployeeLastName]
-- FROM Inventories JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID;

-- GO

-- --Count the names only once on the date it occured

-- GO

-- SELECT DISTINCT InventoryDate, EmployeeName = [EmployeeFirstName]+ '' + [EmployeeLastName]
-- FROM Inventories JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID;

-- GO

--Create this as a view

GO

CREATE VIEW [dbo].[vInventoriesByEmployeesByDates]
AS
SELECT DISTINCT InventoryDate, EmployeeName = [EmployeeFirstName]+ '' + [EmployeeLastName]
FROM Inventories JOIN Employees
ON Inventories.EmployeeID=Employees.EmployeeID;

GO

SELECT * FROM [dbo].[vInventoriesByEmployeesByDates]

GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- --Identify the tables needed

-- SELECT * FROM Categories
-- SELECT * FROM Products
-- SELECT * FROM Inventories

-- --Identify how to join all three tables
-- GO

-- SELECT * FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID; 

-- GO

-- --Identify just the columns that are needed

-- GO

-- SELECT CategoryName, ProductName, InventoryDate, Count 
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID;

-- GO

-- --Add in Order By

-- GO

-- SELECT CategoryName, ProductName, InventoryDate, Count 
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- ORDER BY CategoryName, ProductName, InventoryDate, Count;

-- GO

--Create a view of this query

GO

CREATE VIEW [dbo].[vInventoriesByProductsByCategories]
AS
SELECT TOP 1000000 CategoryName, ProductName, InventoryDate, Count 
FROM Categories JOIN Products
ON Categories.CategoryID=Products.CategoryID
JOIN Inventories
ON Products.ProductID=Inventories.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, Count;

GO

SELECT * FROM [dbo].[vInventoriesByProductsByCategories]

GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- --Identify the tables needed

-- SELECT * FROM Categories
-- SELECT * FROM Products
-- SELECT * FROM Inventories
-- SELECT * FROM Employees

-- --Identify how to join all 4 tables

-- GO

-- SELECT * FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID;

-- GO

-- --Identify the specific columns needed

-- GO

-- SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeName = [EmployeeFirstName] + ' ' + [EmployeeLastName]
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID;

-- GO

-- --Add in Order By

-- GO

-- SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeName = [EmployeeFirstName] + ' ' + [EmployeeLastName]
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID
-- ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;

-- GO

--Create a view 

GO

CREATE VIEW [dbo].[vInventoriesByProductsByEmployees]
AS
SELECT TOP 1000000 CategoryName, ProductName, InventoryDate, Count, EmployeeName = [EmployeeFirstName] + ' ' + [EmployeeLastName]
FROM Categories JOIN Products
ON Categories.CategoryID=Products.CategoryID
JOIN Inventories
ON Products.ProductID=Inventories.ProductID
JOIN Employees
ON Inventories.EmployeeID=Employees.EmployeeID
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;

GO

SELECT * FROM [dbo].[vInventoriesByProductsByEmployees]

GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- --Identify the tables needed

-- SELECT * FROM Categories
-- SELECT * FROM Products
-- SELECT * FROM Inventories
-- SELECT * FROM Employees

-- --Identifty how to join all tables

-- GO

-- SELECT * FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID;

-- GO

-- --Select specific columns needed

-- GO

-- SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeName = [EmployeeFirstName] + ' ' + [EmployeeLastName]
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID;

-- GO


-- --Only select where the product name is Chang or Chai

-- GO

-- SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeName = [EmployeeFirstName] + ' ' + [EmployeeLastName]
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID
-- WHERE Products.ProductID IN
-- 	(
-- 	SELECT ProductID
-- 	FROM Products
-- 	WHERE ProductName in ('Chang', 'Chai')
-- 	);

-- GO

-- --Add in Order By

-- GO

-- SELECT CategoryName, ProductName, InventoryDate, Count, EmployeeName = [EmployeeFirstName] + ' ' + [EmployeeLastName]
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- JOIN Employees
-- ON Inventories.EmployeeID=Employees.EmployeeID
-- WHERE Products.ProductID IN
-- 	(
-- 	SELECT ProductID
-- 	FROM Products
-- 	WHERE ProductName in ('Chang', 'Chai')
-- 	)
-- ORDER BY InventoryDate, CategoryName, ProductName;

-- GO

--Create a View

GO

CREATE VIEW [dbo].[vInventoriesForChaiAndChangByEmployees]
AS
SELECT TOP 1000000 CategoryName, ProductName, InventoryDate, Count, EmployeeName = [EmployeeFirstName] + ' ' + [EmployeeLastName]
FROM Categories JOIN Products
ON Categories.CategoryID=Products.CategoryID
JOIN Inventories
ON Products.ProductID=Inventories.ProductID
JOIN Employees
ON Inventories.EmployeeID=Employees.EmployeeID
WHERE Products.ProductID IN
	(
	SELECT ProductID
	FROM Products
	WHERE ProductName in ('Chang', 'Chai')
	)
ORDER BY InventoryDate, CategoryName, ProductName;

GO

SELECT * FROM [dbo].[vInventoriesForChaiAndChangByEmployees]

GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Identify the tables needed

-- SELECT * FROM Employees

-- --Select specific columns needed

-- SELECT ManagerID, EmployeeFirstName, EmployeeLastName
-- FROM Employees

-- --Add in a self-join (aliases needed)

-- GO

-- SELECT Mgr.EmployeeID as [ManagerID], Mgr.EmployeeFirstName, Mgr.EmployeeLastName, Emp.EmployeeID, Emp.EmployeeFirstName, Emp.EmployeeLastName
-- FROM Employees as Emp JOIN Employees as Mgr
-- ON Emp. ManagerID = Mgr. EmployeeID;

-- GO

-- --Rewrite Column names and add first and last names together

-- GO

-- SELECT [Manager]= Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName, [Employee]=Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
-- FROM Employees as Emp JOIN Employees as Mgr
-- ON Emp. ManagerID = Mgr. EmployeeID

-- GO

-- --Order by manager then employee name

-- GO

-- SELECT [Manager]= Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName, [Employee]=Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
-- FROM Employees as Emp JOIN Employees as Mgr
-- ON Emp. ManagerID = Mgr. EmployeeID
-- ORDER BY Manager, Employee;

-- GO

--Create a view

GO
CREATE VIEW [dbo].[vEmployeesByManager]
AS
SELECT TOP 1000000 [Manager]= Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName, [Employee]=Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
FROM Employees as Emp JOIN Employees as Mgr
ON Emp. ManagerID = Mgr. EmployeeID
ORDER BY Manager, Employee;

GO

SELECT * FROM [dbo].[vEmployeesByManager]

GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 


-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.


-- --Identify all the tables needed

-- SELECT * FROM vCategories
-- SELECT * FROM vProducts
-- SELECT * FROM vInventories
-- SELECT * FROM vEmployees

-- --Identify how to join all 4 tables

-- GO

-- SELECT * FROM vCategories JOIN vProducts
-- ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- ON vProducts.ProductID=vInventories.ProductID
-- JOIN vEmployees
-- ON vInventories.EmployeeID=vEmployees.EmployeeID
-- JOIN vEmployees as vManagers
-- ON vEmployees.ManagerID=vManagers.EmployeeID;

-- GO 

-- --Identify the specific columns you want

-- GO

-- SELECT 
-- 	vCategories.CategoryID, vCategories.CategoryName, 
-- 	vProducts.ProductID, vProducts.ProductName, vProducts.UnitPrice,
-- 	vInventories.InventoryID, vInventories.InventoryDate, vInventories.Count,
-- 	vEmployees.EmployeeID, Employee = vEmployees.EmployeeFirstName + '' + vEmployees.EmployeeLastName,
-- Manager = vManagers.EmployeeFirstName + ' ' + vManagers.EmployeeLastName
-- FROM vCategories JOIN vProducts
-- ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- ON vProducts.ProductID=vInventories.ProductID
-- JOIN vEmployees
-- ON vInventories.EmployeeID=vEmployees.EmployeeID
-- JOIN vEmployees as vManagers
-- ON vEmployees.ManagerID=vManagers.EmployeeID;

-- GO 

-- --Add in Order By
-- GO

-- SELECT 
-- 	vCategories.CategoryID, vCategories.CategoryName, 
-- 	vProducts.ProductID, vProducts.ProductName, vProducts.UnitPrice,
-- 	vInventories.InventoryID, vInventories.InventoryDate, vInventories.Count,
-- 	vEmployees.EmployeeID, Employee = vEmployees.EmployeeFirstName + '' + vEmployees.EmployeeLastName,
-- Manager = vManagers.EmployeeFirstName + ' ' + vManagers.EmployeeLastName
-- FROM vCategories JOIN vProducts
-- ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- ON vProducts.ProductID=vInventories.ProductID
-- JOIN vEmployees
-- ON vInventories.EmployeeID=vEmployees.EmployeeID
-- JOIN vEmployees as vManagers
-- ON vEmployees.ManagerID=vManagers.EmployeeID
-- ORDER BY CategoryName, ProductID, InventoryID, Employee;

-- GO 

--Create a View

GO

CREATE VIEW [dbo].[vInventoriesByProductsByCategoriesByEmployees]
AS
SELECT TOP 1000000
	vCategories.CategoryID, vCategories.CategoryName, 
	vProducts.ProductID, vProducts.ProductName, vProducts.UnitPrice,
	vInventories.InventoryID, vInventories.InventoryDate, vInventories.Count,
	vEmployees.EmployeeID, Employee = vEmployees.EmployeeFirstName + '' + vEmployees.EmployeeLastName,
Manager = vManagers.EmployeeFirstName + ' ' + vManagers.EmployeeLastName
FROM vCategories JOIN vProducts
ON vCategories.CategoryID=vProducts.CategoryID
JOIN vInventories
ON vProducts.ProductID=vInventories.ProductID
JOIN vEmployees
ON vInventories.EmployeeID=vEmployees.EmployeeID
JOIN vEmployees as vManagers
ON vEmployees.ManagerID=vManagers.EmployeeID
ORDER BY CategoryName, ProductID, InventoryID, Employee;

GO 

SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]

GO
/***************************************************************************************/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/