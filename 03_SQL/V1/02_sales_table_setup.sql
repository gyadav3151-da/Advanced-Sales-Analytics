-- Sales Performance & Growth Analysis
-- Author: Gaurav Yadav
-- Description: SQL scripts of final table used for data preparation and analysis
-- Dataset: Superstore Sales Dataset

/*
==================================================
SUPERSTORE SALES ANALYSIS PROJECT
==================================================
This project demonstrates SQL data cleaning,
data validation, and exploratory data analysis
on a retail sales dataset.

Key analyses include:
- Sales and profit performance
- Regional performance
- Category and product profitability
- Customer segment analysis
- Discount impact on profitability

The cleaned dataset is later used for a
Power BI dashboard.
==================================================
*/


/* 
---------------------------------------------------------
CREATE DATABASE AND SELECT IT
---------------------------------------------------------
Creates a new database for the sales analysis project
and sets it as the active database.
*/
/* =============================================
   CREATE DATABASE AND SELECT IT
============================================= */

IF DB_ID('SalesAnalysisDB') IS NULL
BEGIN
    CREATE DATABASE SalesAnalysisDB;
END
GO

USE SalesAnalysisDB;
GO


/*
---------------------------------------------------------
DROP TABLE IF EXISTS
---------------------------------------------------------
Removes the table if it already exists so the script
can be re-run without errors.
*/
IF OBJECT_ID('Superstore_sales', 'U') IS NOT NULL
DROP TABLE Superstore_sales;


/*
---------------------------------------------------------
CREATE CLEAN SALES TABLE
---------------------------------------------------------
Creates the final structured table that will store the
cleaned sales data imported from the staging table.
*/
CREATE TABLE Superstore_sales (
    Row_ID INT PRIMARY KEY,
    Order_ID NVARCHAR(20),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode NVARCHAR(50),
    Customer_ID NVARCHAR(50),
    Customer_Name NVARCHAR(100),
    Segment NVARCHAR(50),
    Country NVARCHAR(50),
    City NVARCHAR(50),
    [State] NVARCHAR(50),
    Postal_Code NVARCHAR(50),
    Region NVARCHAR(50),
    Product_ID NVARCHAR(30),
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(50),
    Product_Name NVARCHAR(150),
    Quantity INT,
    Sales DECIMAL(12,2),
    Discount DECIMAL(5,2),
    Profit DECIMAL(12,2)
);


/*
---------------------------------------------------------
INSERT CLEANED DATA
---------------------------------------------------------
Loads data from the staging table and converts fields
to the appropriate data types using TRY_CAST.

TRY_CAST prevents the query from failing if invalid
values exist by returning NULL instead of an error.
*/
INSERT INTO Superstore_sales
SELECT
    TRY_CAST(Row_ID AS INT),
    Order_ID,
    TRY_CAST(Order_Date AS DATE),
    TRY_CAST(Ship_Date AS DATE),
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country,
    City,
    [State],
    Postal_Code,
    Region,
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    TRY_CAST(Quantity AS INT),
    TRY_CAST(Sales AS DECIMAL(10,2)),
    TRY_CAST(Discount AS DECIMAL(5,2)),
    TRY_CAST(Profit AS DECIMAL(10,2))
FROM Superstore_sales_staging;


/*
---------------------------------------------------------
DATA VALIDATION
---------------------------------------------------------
Ensures the number of records loaded matches the
original staging table.
*/
SELECT COUNT(*) AS count_staging FROM Superstore_sales_staging;
SELECT COUNT(*) AS count_final FROM Superstore_sales;


/*
---------------------------------------------------------
CHECK FOR NULL VALUES
---------------------------------------------------------
Identifies rows where type conversion failed during
the data cleaning process.
*/
SELECT *
FROM Superstore_sales
WHERE ROW_ID IS NULL OR ROW_ID = '' OR
	Order_ID IS NULL OR Order_ID = '' OR 
	Order_Date IS NULL OR Order_Date = '' OR 
	Ship_Date IS NULL OR Ship_Date = '' OR 
	Ship_Mode IS NULL OR Ship_Mode = '' OR
	Customer_ID IS NULL OR Customer_ID = '' OR
	Customer_Name IS NULL OR Customer_Name = '' OR
	Segment IS NULL OR Segment = '' OR
	Country IS NULL OR Country = '' OR
	City IS NULL OR City = '' OR
	[State] IS NULL OR [State] = '' OR
	Postal_Code IS NULL OR Postal_Code = '' OR
	Region IS NULL OR Region = '' OR 
	Product_ID IS NULL OR Product_ID = '' OR 
	Category IS NULL OR Category = '' OR
	Sub_Category IS NULL OR Sub_Category = '' OR
	Product_Name IS NULL OR Product_Name = '' OR
	Quantity IS NULL OR Quantity = '' OR
	Sales IS NULL OR Sales = '' OR
	Discount IS NULL OR Discount = '' OR
	Profit IS NULL OR Profit = '';


/*
---------------------------------------------------------
BASIC DATASET OVERVIEW
---------------------------------------------------------
*/
SELECT *
FROM Superstore_sales;
