-- Sales Performance & Growth Analysis
-- Author: Gaurav Yadav

/*
==================================================
SUPERSTORE SALES – STAGING TABLE
==================================================
This script creates a staging table used to import
raw sales data from a CSV file before performing
data cleaning and transformation.

The staging table stores all columns as NVARCHAR
to prevent data load failures caused by incorrect
data types.

After loading, the data will be validated and then
moved to a cleaned production table.
==================================================
*/


/*
--------------------------------------------------
CREATE DATABASE AND SELECT IT
--------------------------------------------------
Creates the database if it does not already exist
and sets it as the active database.
*/
IF DB_ID('SalesAnalysisDB') IS NULL
BEGIN
    CREATE DATABASE SalesAnalysisDB;
END
GO

USE SalesAnalysisDB;
GO


/*
--------------------------------------------------
DROP EXISTING STAGING TABLE
--------------------------------------------------
Removes the staging table if it already exists so
the script can be executed multiple times without
errors.
*/
IF OBJECT_ID('Superstore_sales_staging', 'U') IS NOT NULL
DROP TABLE Superstore_sales_staging;


/*
--------------------------------------------------
CREATE STAGING TABLE
--------------------------------------------------
Creates a staging table to temporarily store the
raw imported dataset.

All columns are stored as NVARCHAR so that data
loads successfully even if values contain format
issues or inconsistent types.
*/
CREATE TABLE Superstore_sales_staging (
	Row_ID NVARCHAR(50),
    Order_ID NVARCHAR(50),
    Order_Date NVARCHAR(50),
    Ship_Date NVARCHAR(50),
    Ship_Mode NVARCHAR(50),
    Customer_ID NVARCHAR(50),
    Customer_Name NVARCHAR(100),
    Segment NVARCHAR(50),
    Country NVARCHAR(50),
    City NVARCHAR(50),
    [State] NVARCHAR(100),
    Postal_Code NVARCHAR(100),
    Region NVARCHAR(100),
    Product_ID NVARCHAR(1000),
    Category NVARCHAR(100),
    Sub_Category NVARCHAR(100),
    Product_Name NVARCHAR(150),
    Quantity NVARCHAR(100),
    Sales NVARCHAR(50),
    Discount NVARCHAR(50),
    Profit NVARCHAR(50)
);


/*
--------------------------------------------------
IMPORT DATA FROM CSV
--------------------------------------------------
Uses BULK INSERT to load the raw CSV file into
the staging table.

FIRSTROW = 2
    Skips the header row in the CSV file.

FIELDTERMINATOR = '|'
    Specifies the column delimiter used in the file.

ROWTERMINATOR = '0x0a'
    Specifies the end-of-line character.

CODEPAGE = '65001'
    Ensures the file is read using UTF-8 encoding.

TABLOCK
    Improves bulk load performance by locking the
    table during the insert operation.
*/
BULK INSERT Superstore_sales_staging
FROM 'C:\Path\To\Your\v1_superstore_sql_ready.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = '|',
	ROWTERMINATOR = '0x0a',
	CODEPAGE = '65001',
	TABLOCK
);


/*
--------------------------------------------------
VALIDATE DATA LOAD
--------------------------------------------------
Checks the total number of records loaded into
the staging table.
*/
SELECT COUNT(*) AS total_rows
FROM Superstore_sales_staging;


/*
--------------------------------------------------
CHECK FOR NULL VALUES
--------------------------------------------------
Identifies rows where important fields may be
missing after import.
*/
SELECT *
FROM Superstore_sales_staging
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
--------------------------------------------------
REVIEW RAW DATA
--------------------------------------------------
Displays the imported data for inspection.
*/
SELECT *
FROM Superstore_sales_staging;


/*
--------------------------------------------------
CHECK DATA TYPE CONVERSION ISSUES
--------------------------------------------------
Identifies rows where the Quantity column cannot
be converted to an integer, which may indicate
data quality issues in the source file.
*/
SELECT *
FROM Superstore_sales_staging
WHERE TRY_CAST(Quantity AS INT) IS NULL
	AND Quantity IS NOT NULL
	AND Quantity <> '';
