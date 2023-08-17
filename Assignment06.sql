--*************************************************************************--
-- Title: Assignment06
-- Author: NUpadhyay
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,NUpadhyay,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_NUpadhyay')
	 Begin 
	  Alter Database [Assignment06DB_NUpadhyay] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_NUpadhyay;
	 End
	Create Database Assignment06DB_NUpadhyay;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_NUpadhyay;

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
GO
-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE VIEW [dbo].[vCategories] WITH SCHEMABINDING
AS
SELECT CategoryID, CategoryName
FROM dbo.Categories;
GO

CREATE VIEW [dbo].[vProducts] WITH SCHEMABINDING
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products;
GO

CREATE VIEW [dbo].[vEmployees] WITH SCHEMABINDING
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees;
go 
CREATE VIEW [dbo].[vInventories] WITH SCHEMABINDING
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
FROM dbo.Inventories;
GO
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
-- Deny SELECT on tables
DENY SELECT ON dbo.Categories TO PUBLIC;
DENY SELECT ON dbo.Products TO PUBLIC;
DENY SELECT ON dbo.Employees TO PUBLIC;
DENY SELECT ON dbo.Inventories TO PUBLIC;

-- Grant SELECT on views
GRANT SELECT ON [dbo].[vCategories] TO PUBLIC;
GRANT SELECT ON [dbo].[vProducts] TO PUBLIC;
GRANT SELECT ON [dbo].[vEmployees] TO PUBLIC;
GRANT SELECT ON [dbo].[vInventories] TO PUBLIC;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
CREATE VIEW [dbo].[vProductsByCategories] WITH SCHEMABINDING
AS
SELECT c.CategoryName, p.ProductName, p.UnitPrice
FROM dbo.Categories AS c
JOIN dbo.Products AS p ON c.CategoryID = p.CategoryID;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
CREATE VIEW [dbo].[vInventoriesByProductsByDates] WITH SCHEMABINDING
AS
SELECT p.ProductName, i.InventoryDate, i.[Count]
FROM dbo.Products AS p
JOIN dbo.Inventories AS i ON p.ProductID = i.ProductID;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
CREATE VIEW [dbo].[vInventoriesByEmployeesByDates] WITH SCHEMABINDING
AS
SELECT i.InventoryDate, MIN(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
FROM dbo.Inventories AS i
JOIN dbo.Employees AS e ON i.EmployeeID = e.EmployeeID
GROUP BY i.InventoryDate;
GO


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
CREATE VIEW [dbo].[vInventoriesByProductsByCategories] WITH SCHEMABINDING
AS
SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.[Count]
FROM dbo.Categories AS c
JOIN dbo.Products AS p ON c.CategoryID = p.CategoryID
JOIN dbo.Inventories AS i ON p.ProductID = i.ProductID;
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
CREATE VIEW [dbo].[vInventoriesByProductsByEmployees] WITH SCHEMABINDING
AS
SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], 
       e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
FROM dbo.Categories AS c
JOIN dbo.Products AS p ON c.CategoryID = p.CategoryID
JOIN dbo.Inventories AS i ON p.ProductID = i.ProductID
JOIN dbo.Employees AS e ON i.EmployeeID = e.EmployeeID;
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
CREATE VIEW [dbo].[vInventoriesForChaiAndChangByEmployees] WITH SCHEMABINDING
AS
SELECT c.CategoryName, p.ProductName, i.InventoryDate, i.[Count], 
       e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
FROM dbo.Categories AS c
JOIN dbo.Products AS p ON c.CategoryID = p.CategoryID
JOIN dbo.Inventories AS i ON p.ProductID = i.ProductID
JOIN dbo.Employees AS e ON i.EmployeeID = e.EmployeeID
WHERE p.ProductName IN ('Chai', 'Chang');
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE VIEW [dbo].[vEmployeesAndManagers] WITH SCHEMABINDING
AS
SELECT e1.EmployeeFirstName + ' ' + e1.EmployeeLastName AS EmployeeName,
       e2.EmployeeFirstName + ' ' + e2.EmployeeLastName AS ManagerName
FROM dbo.Employees AS e1
JOIN dbo.Employees AS e2 ON e1.ManagerID = e2.EmployeeID;
GO


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
CREATE VIEW [dbo].[vAllDataFromAllViews] WITH SCHEMABINDING
AS
SELECT c.CategoryName, p.ProductName, i.InventoryID, i.InventoryDate, i.[Count],
       e1.EmployeeFirstName + ' ' + e1.EmployeeLastName AS EmployeeName,
       e2.EmployeeFirstName + ' ' + e2.EmployeeLastName AS ManagerName
FROM dbo.Categories AS c
JOIN dbo.Products AS p ON c.CategoryID = p.CategoryID
JOIN dbo.Inventories AS i ON p.ProductID = i.ProductID
JOIN dbo.Employees AS e1 ON i.EmployeeID = e1.EmployeeID
JOIN dbo.Employees AS e2 ON e1.ManagerID = e2.EmployeeID;
GO


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

/***************************************************************************************/