-- Sales Performance & Growth Analysis
-- Author: Gaurav Yadav
-- Description: SQL scripts used for analysis


/*
--------------------------------------------------
SELECTING DATABASE
--------------------------------------------------
*/
USE SalesAnalysisDB;
GO


/*
---------------------------------------------------------
BASIC DATASET OVERVIEW
---------------------------------------------------------
Provides a high level summary of the dataset including
total transactions and unique customers.
*/
SELECT COUNT(*) AS Total_Transactions FROM Superstore_sales;
SELECT COUNT(DISTINCT Customer_ID) AS Total_Customers FROM Superstore_sales;


/*
---------------------------------------------------------
OVERALL BUSINESS PERFORMANCE
---------------------------------------------------------
Calculates total sales, total profit, and overall
profit margin across the entire dataset.
*/
SELECT ROUND(SUM(Sales),2) AS Total_Sales,
	ROUND(SUM(Profit),2) AS Total_Profit,
	CAST(ROUND(SUM(Profit) / NULLIF(SUM(Sales),0), 4) AS DECIMAL(10,4)) AS Profit_Margin
FROM Superstore_sales;


/*
---------------------------------------------------------
YEARLY SALES PERFORMANCE
---------------------------------------------------------
Analyzes total sales, profit, and margin by year.
Useful for identifying growth trends.
*/
SELECT YEAR(Order_Date) AS [Year], ROUND(SUM(Sales),2) AS Total_Sales,
	ROUND(SUM(Profit),2) AS Total_Profit,
	CAST(ROUND(SUM(Profit) / NULLIF(SUM(Sales),0), 4) AS DECIMAL(10,4)) AS Profit_Margin
FROM Superstore_sales
GROUP BY YEAR(Order_Date)
ORDER BY YEAR(Order_Date);


/*
---------------------------------------------------------
MONTHLY SALES TREND
---------------------------------------------------------
Uses a calendar table to aggregate sales by month
and year for time-series analysis.
*/
SELECT
    cdr.[Year],
    cdr.[Month_Name],
    cdr.[Month_Number],
    ROUND(SUM(ss.Sales), 2) AS Monthly_Sales
FROM Superstore_sales ss
INNER JOIN Calendar cdr 
    ON cdr.Calendar_Date = ss.Order_Date
GROUP BY cdr.[Year], cdr.[Month_Name], cdr.[Month_Number]
ORDER BY cdr.[Year], cdr.[Month_Number];


/*
---------------------------------------------------------
REGIONAL PERFORMANCE
---------------------------------------------------------
Evaluates sales, profit, and profit margin across
different geographic regions.
*/
SELECT
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    CAST(ROUND(SUM(Profit) / NULLIF(SUM(Sales),0), 4) AS DECIMAL(10,4)) AS Profit_Margin
FROM Superstore_sales
GROUP BY Region
ORDER BY Total_Sales DESC;


/*
---------------------------------------------------------
CATEGORY AND SUBCATEGORY PERFORMANCE
---------------------------------------------------------
Analyzes how different product categories and
subcategories contribute to overall revenue and profit.
*/
WITH CTE_category_tables AS (
    SELECT Category, SUM(Sales) AS Category_Sales
    FROM Superstore_sales
    GROUP BY Category)
SELECT
    s.Category, s.Sub_Category,
    ROUND(SUM(s.Sales), 2) AS Sub_Category_Sales,
    ROUND(SUM(s.Profit), 2) AS Sub_Category_Profit,
    CAST(ROUND(SUM(s.Profit) / NULLIF(SUM(s.Sales),0), 4) AS DECIMAL(10,4)) AS Sub_Category_Profit_Margin
FROM Superstore_sales s
INNER JOIN CTE_category_tables c
    ON c.Category = s.Category
GROUP BY s.Category, s.Sub_Category, c.Category_Sales
ORDER BY c.Category_Sales DESC, Sub_Category_Sales DESC;


/*
---------------------------------------------------------
CUSTOMER SEGMENT ANALYSIS
---------------------------------------------------------
Examines sales and profitability across customer
segments (Consumer, Corporate, Home Office).
*/
SELECT
    Segment,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    CAST(ROUND(SUM(Profit) / NULLIF(SUM(Sales),0), 4) AS DECIMAL(10,4)) AS Profit_Margin
FROM Superstore_sales
GROUP BY Segment
ORDER BY Total_Sales DESC;


/*
---------------------------------------------------------
LOSS-MAKING PRODUCT AREAS
---------------------------------------------------------
Identifies categories and subcategories where
total profit is negative.
*/
SELECT
    Category, Sub_Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM Superstore_sales
GROUP BY Category, Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit;


/*
---------------------------------------------------------
TOP PROFITABLE PRODUCTS
---------------------------------------------------------
Lists the top 10 products generating the highest profit.
*/
SELECT TOP 10
    Product_Name,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM Superstore_sales
GROUP BY Product_name
ORDER BY Total_Profit DESC;


/*
---------------------------------------------------------
LEAST PROFITABLE PRODUCTS
---------------------------------------------------------
Identifies the 10 products generating the lowest profit.
*/
SELECT TOP 10
    Product_Name,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM Superstore_sales
GROUP BY Product_name
ORDER BY Total_Profit ASC;


/*
---------------------------------------------------------
REGIONAL PROFIT TRENDS
---------------------------------------------------------
Analyzes how profit changes across regions over time.
*/
SELECT
    s.Region,
    cdr.[YEAR],
    ROUND(SUM(profit), 2) AS Yearly_Profit
FROM Superstore_sales s
JOIN Calendar cdr
    ON cdr.Calendar_Date = s.Order_Date
GROUP BY s.Region, cdr.[YEAR]
ORDER BY s.Region, cdr.[YEAR];


/*
---------------------------------------------------------
DISCOUNT IMPACT ANALYSIS
---------------------------------------------------------
Examines how different discount levels affect
sales performance and profitability.
*/
SELECT
    Discount,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
   CAST(ROUND(SUM(Profit) / NULLIF(SUM(Sales),0), 4) AS DECIMAL(10,4)) AS Profit_Margin
FROM Superstore_sales
GROUP BY Discount
ORDER BY Discount;
