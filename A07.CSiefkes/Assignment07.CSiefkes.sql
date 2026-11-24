--*************************************************************************--
-- Title: Assignment07
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2026-11-23,CSiefkes,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_CSiefkes')
	 Begin 
	  Alter Database [Assignment07DB_CSiefkes] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_CSiefkes;
	 End
	Create Database Assignment07DB_CSiefkes;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_CSiefkes;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --

-- --Identify the tables needed

-- GO
-- SELECT * FROM Products
-- GO

-- --Identify the columns needed

-- GO
-- SELECT ProductName, UnitPrice
-- FROM Products
-- GO

-- --Update UnitPrice to be in dollars

-- GO
-- SELECT
-- ProductName, 
-- FORMAT (UnitPrice, 'C', 'en-US') AS 'Unit Price'
-- FROM Products
-- GO

-- --Add in Order By Product Name

-- GO
-- SELECT
-- ProductName, 
-- FORMAT (UnitPrice, 'C', 'en-US') AS 'Unit Price'
-- FROM Products
-- ORDER BY ProductName
-- GO

--Format to make it cleaner

GO
SELECT
	ProductName, 
	FORMAT (UnitPrice, 'C', 'en-US') AS 'Unit Price'
FROM Products
ORDER BY ProductName;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- <Put Your Code Here> --

-- --Identity the tables needed

-- GO
-- SELECT * FROM Categories

-- SELECT * FROM Products

-- GO

-- --Join the two tables based on Category ID

-- GO

-- SELECT * FROM Products JOIN Categories
-- ON Products.CategoryID = Categories.CategoryID;

-- GO

-- --Identify just the columns needed

-- GO

-- SELECT CategoryName, ProductName, UnitPrice
-- FROM Products JOIN Categories
-- ON Products.CategoryID = Categories.CategoryID;

-- GO

-- --Have UnitPrice be reflected as dollars

-- GO

-- SELECT CategoryName, ProductName, FORMAT(UnitPrice,'C','en-US') AS 'Unit Price'
-- FROM Products JOIN Categories
-- ON Products.CategoryID = Categories.CategoryID;

-- GO

-- --Add in OrderBy for Category and Product

-- GO

-- SELECT CategoryName, ProductName, FORMAT(UnitPrice,'C','en-US') AS 'Unit Price'
-- FROM Products JOIN Categories
-- ON Products.CategoryID = Categories.CategoryID
-- ORDER BY CategoryName, ProductName;

-- GO

--Format it to be cleaner

GO

SELECT 
	CategoryName,
	ProductName,
	FORMAT(UnitPrice,'C','en-US') AS 'Unit Price'
FROM Products JOIN Categories
ON Products.CategoryID = Categories.CategoryID
ORDER BY CategoryName, ProductName;

GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- --Identify the tables needed

-- SELECT * FROM Products

-- SELECT * FROM Inventories

-- --Join the two tables

-- GO

-- SELECT * FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- GO

-- --Select just the columns needed

-- GO

-- SELECT ProductName, InventoryDate, Count
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- GO

-- --Update the format of the inventory date

-- GO

-- SELECT ProductName, FORMAT (InventoryDate, 'MMMM, yyyy') AS 'InventoryDate', Count AS 'InventoryCount'
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- GO

-- --Order by Product and Date

-- GO

-- SELECT ProductName, FORMAT (InventoryDate, 'MMMM,yyyy') AS 'InventoryDate', Count AS 'InventoryCount'
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID
-- ORDER BY ProductName, Inventories.InventoryDate;

-- GO

--Format it to make it cleaner

GO

SELECT 
	ProductName,
	FORMAT (InventoryDate, 'MMMM,yyyy') AS 'InventoryDate',
	Count AS 'InventoryCount'
FROM Products JOIN Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY ProductName, Inventories.InventoryDate;

GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- --Identify the tables needed

-- SELECT * FROM Products

-- SELECT * FROM Inventories

-- --Join the two tables

-- GO

-- SELECT * FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- GO

-- --Select just the columns needed

-- GO

-- SELECT ProductName, InventoryDate, Count
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- GO

-- --Update the format of the inventory date

-- GO

-- SELECT ProductName, FORMAT (InventoryDate, 'MMMM, yyyy') AS 'InventoryDate', Count AS 'InventoryCount'
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID;

-- GO

-- --Order by Product and Date

-- GO

-- SELECT ProductName, FORMAT (InventoryDate, 'MMMM,yyyy') AS 'InventoryDate', Count AS 'InventoryCount'
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID
-- ORDER BY ProductName, Inventories.InventoryDate;

-- GO

-- --Format it to make it cleaner

-- GO

-- SELECT 
-- 	ProductName,
-- 	FORMAT (InventoryDate, 'MMMM,yyyy') AS 'InventoryDate',
-- 	Count AS 'InventoryCount'
-- FROM Products JOIN Inventories
-- ON Products.ProductID = Inventories.ProductID
-- ORDER BY ProductName, Inventories.InventoryDate;

-- GO

--Make the query into a view

GO

CREATE VIEW vProductInventories
AS
SELECT TOP 10000
	ProductName,
	FORMAT (InventoryDate, 'MMMM,yyyy') AS 'InventoryDate',
	Count AS 'InventoryCount'
FROM Products JOIN Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY ProductName, Inventories.InventoryDate;

GO

-- Check that it works: Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- --Identify the tables needed

-- SELECT * FROM Categories
-- SELECT * FROM Inventories
-- SELECT * FROM Products

-- --Join all 3 tables

-- GO

-- SELECT * FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID;

-- GO

-- --Identify just the columns needed

-- GO

-- SELECT CategoryName, InventoryDate, Count FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID;

-- GO

-- --Format the date to be Month, Year

-- GO

-- SELECT CategoryName, FORMAT(InventoryDate,'MMMM, yyyy') AS 'Inventory Date', Count AS 'InventoryCount' FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID;

-- GO

-- --Aggregate inventory count for each month, adds in group by so we can aggregate

-- GO

-- SELECT CategoryName, FORMAT(InventoryDate,'MMMM, yyyy') AS 'Inventory Date', SUM (Count) AS 'InventoryCountbyCategory' FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- GROUP BY CategoryName, InventoryDate;

-- GO


-- --Add in the order by for product and date

-- GO

-- SELECT CategoryName, FORMAT(InventoryDate,'MMMM, yyyy') AS 'Inventory Date', SUM (Count) AS 'InventoryCountbyCategory' FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- GROUP BY CategoryName, InventoryDate
-- ORDER BY CategoryName, InventoryDate;

-- GO

-- --Format it to be cleaner

-- GO

-- SELECT
-- 	CategoryName,
-- 	FORMAT(InventoryDate,'MMMM, yyyy') AS 'Inventory Date',
-- 	SUM (Count) AS 'InventoryCountbyCategory' 
-- FROM Categories JOIN Products
-- ON Categories.CategoryID=Products.CategoryID
-- JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- GROUP BY CategoryName, InventoryDate
-- ORDER BY CategoryName, InventoryDate;

-- GO

--Add in a view 

GO 

CREATE VIEW vCategoryInventories
AS
SELECT TOP 10000
	CategoryName,
	FORMAT(InventoryDate,'MMMM, yyyy') AS 'Inventory Date',
	SUM (Count) AS 'InventoryCountbyCategory' 
FROM Categories JOIN Products
ON Categories.CategoryID=Products.CategoryID
JOIN Inventories
ON Products.ProductID=Inventories.ProductID
GROUP BY CategoryName, InventoryDate
ORDER BY CategoryName, InventoryDate;

GO

-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --

-- --Identify all tables needed

-- SELECT * FROM Products
-- SELECT * FROM Inventories

-- --Join the 2 tables

-- GO

-- SELECT * FROM Products JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID;

-- GO

-- --Identify which columns are needed

-- GO

-- SELECT ProductName, InventoryDate, Count FROM Products JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID;

-- GO

-- --Update date format to be month and year

-- GO

-- SELECT ProductName, FORMAT(InventoryDate, 'MMMM, yyyy') AS 'InventoryDate', SUM(Count) AS 'InventoryCount' FROM Products JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID;

-- GO

-- --Add in a previous month count

-- GO

-- SELECT ProductName, FORMAT(InventoryDate, 'MMMM, yyyy') AS 'InventoryDate', SUM(Count) AS 'InventoryCount', LAG(SUM(Count)) OVER (PARTITION BY ProductName ORDER BY Inventories.InventoryDate) AS 'PreviousMonthCount' FROM Products JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- GROUP BY ProductName, InventoryDate, Count

-- GO

-- --Add in that if Null then the return is 0

-- GO

-- SELECT ProductName, FORMAT(InventoryDate, 'MMMM, yyyy') AS 'InventoryDate', SUM(Count) AS 'InventoryCount', ISNULL (LAG(SUM(Count)) OVER (PARTITION BY ProductName ORDER BY Inventories.InventoryDate), 0) AS 'PreviousMonthCount' FROM Products JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- GROUP BY ProductName, Inventories.InventoryDate;

-- GO

-- --Order by Product and Date

-- GO

-- SELECT ProductName, FORMAT(InventoryDate, 'MMMM, yyyy') AS 'InventoryDate', SUM(Count) AS 'InventoryCount', ISNULL (LAG(SUM(Count)) OVER (PARTITION BY ProductName ORDER BY Inventories.InventoryDate), 0) AS 'PreviousMonthCount' FROM Products JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- GROUP BY ProductName, Inventories.InventoryDate
-- ORDER BY ProductName, Inventories.InventoryDate;

-- GO

-- --Format it to look cleaner

-- GO 

-- SELECT TOP 100000 
-- 	ProductName,
-- 	FORMAT(InventoryDate, 'MMMM, yyyy') AS 'InventoryDate',
-- 	SUM(Count) AS 'InventoryCount',
-- 	ISNULL (LAG(SUM(Count)) OVER (PARTITION BY ProductName ORDER BY Inventories.InventoryDate), 0) AS 'PreviousMonthCount'
-- FROM Products JOIN Inventories
-- ON Products.ProductID=Inventories.ProductID
-- GROUP BY ProductName, Inventories.InventoryDate
-- ORDER BY ProductName, Inventories.InventoryDate;

-- GO

--Create a view

GO

CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS
SELECT TOP 100000 
	ProductName,
	FORMAT(InventoryDate, 'MMMM, yyyy') AS 'InventoryDate',
	SUM(Count) AS 'InventoryCount',
	ISNULL (LAG(SUM(Count)) OVER (PARTITION BY ProductName ORDER BY Inventories.InventoryDate), 0) AS 'PreviousMonthCount'
FROM Products JOIN Inventories
ON Products.ProductID=Inventories.ProductID
GROUP BY ProductName, Inventories.InventoryDate
ORDER BY ProductName, Inventories.InventoryDate;

GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- -- Utilize previous view to create the new KPI column

-- GO

-- SELECT ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviouscountKPI = CASE
-- WHEN InventoryCount > PreviousMonthCount THEN '1'
-- WHEN InventoryCount = PreviousMonthCount THEN '0'
-- WHEN InventoryCount < PreviousMonthCount THEN '-1'
-- END 
-- FROM vProductInventoriesWithPreviousMonthCounts
-- ORDER BY ProductName;

-- GO

-- --Format this to look nicer

-- GO

-- SELECT 
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount,
-- 	PreviousMonthCount,
-- 	CountVsPreviouscountKPI = CASE
-- WHEN InventoryCount > PreviousMonthCount THEN '1'
-- WHEN InventoryCount = PreviousMonthCount THEN '0'
-- WHEN InventoryCount < PreviousMonthCount THEN '-1'
-- END 
-- FROM vProductInventoriesWithPreviousMonthCounts
-- ORDER BY ProductName;

-- GO

--Create a new view

GO

CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
SELECT TOP 100000
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviouscountKPI = CASE
WHEN InventoryCount > PreviousMonthCount THEN '1'
WHEN InventoryCount = PreviousMonthCount THEN '0'
WHEN InventoryCount < PreviousMonthCount THEN '-1'
END 
FROM vProductInventoriesWithPreviousMonthCounts
ORDER BY ProductName;

GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

-- -- Create a basic query of the columns needed and from the previous view used

-- GO

-- SELECT ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
-- FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;

-- GO

-- --Add in a where clause to filter down results

-- GO

-- SELECT ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
-- FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
-- WHERE CountVsPreviouscountKPI = 1;

-- GO

-- -- Update the where clause so that it can hold any value 

-- GO

-- DECLARE @KPI INT
-- SELECT ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
-- FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
-- WHERE CountVsPreviouscountKPI = CAST (@KPI AS VARCHAR(10));

-- GO

--Create the function

GO

CREATE FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs 
(@KPI INT)
RETURNS TABLE
AS
RETURN
(
SELECT ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
WHERE CountVsPreviouscountKPI = CAST (@KPI AS VARCHAR(10))
);

GO


Print 'Note: You will get an error until the views and functions are created!'
/* Check that it works:
Select * From vProductInventories;
Select * From vCategoryInventories;
Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/