/*
===========================================================
SUPERSTORE SALES V2 - BUSINESS ANALYSIS
===========================================================

Purpose:
- Analyze overall business performance.
- Identify trends across time, geography, and products.
- Evaluate profitability across customer segments.
- Investigate the impact of discounting on profitability.

Improvements Over V1:
- Analysis is now based on the fact table rather
  than the original source table.
- Time-based analysis uses a reusable calendar
  dimension for consistent date attributes.
- Separates data preparation from business analysis,
  improving maintainability and readability.

Data Sources:
- fact_superstore_sales
- dim_calendar

===========================================================
*/

USE AdvancedSalesAnalytics;
GO


/*
---------------------------------------------------------
BASIC DATASET OVERVIEW
---------------------------------------------------------
Provides a high-level summary of the dataset including
total transactions and unique customers.
---------------------------------------------------------
*/

SELECT
    COUNT(*) AS total_transactions
FROM fact_superstore_sales;

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM fact_superstore_sales;



/*
---------------------------------------------------------
OVERALL BUSINESS PERFORMANCE
---------------------------------------------------------
Calculates total sales, total profit, and overall
profit margin across the entire dataset.
---------------------------------------------------------
*/

SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    CAST(
        ROUND(
            SUM(profit) / NULLIF(SUM(sales), 0),
            4
        ) AS DECIMAL(10,4)
    ) AS profit_margin
FROM fact_superstore_sales;



/*
---------------------------------------------------------
YEARLY SALES PERFORMANCE
---------------------------------------------------------
Analyzes total sales, profit, and margin by year.

Uses the calendar dimension to provide consistent
date attributes across analyses.
---------------------------------------------------------
*/

SELECT
    c.[year],
    ROUND(SUM(f.sales), 2) AS total_sales,
    ROUND(SUM(f.profit), 2) AS total_profit,
    CAST(
        ROUND(
            SUM(f.profit) / NULLIF(SUM(f.sales), 0),
            4
        ) AS DECIMAL(10,4)
    ) AS profit_margin
FROM fact_superstore_sales f
INNER JOIN dim_calendar c
    ON c.calendar_date = f.order_date
GROUP BY
    c.[year]
ORDER BY
    c.[year];



/*
---------------------------------------------------------
MONTHLY SALES TREND
---------------------------------------------------------
Aggregates monthly sales to reveal seasonality and
long-term revenue patterns.

Uses the calendar dimension to ensure consistent
time-based reporting.
---------------------------------------------------------
*/

SELECT
    c.[year],
    c.month_name,
    c.month_number,
    ROUND(SUM(f.sales), 2) AS monthly_sales
FROM fact_superstore_sales f
INNER JOIN dim_calendar c
    ON c.calendar_date = f.order_date
GROUP BY
    c.[year],
    c.month_name,
    c.month_number
ORDER BY
    c.[year],
    c.month_number;



/*
---------------------------------------------------------
REGIONAL PERFORMANCE
---------------------------------------------------------
Evaluates sales, profit, and profit margin across
different geographic regions.
---------------------------------------------------------
*/

SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    CAST(
        ROUND(
            SUM(profit) / NULLIF(SUM(sales), 0),
            4
        ) AS DECIMAL(10,4)
    ) AS profit_margin
FROM fact_superstore_sales
GROUP BY
    region
ORDER BY
    total_sales DESC;



/*
---------------------------------------------------------
CATEGORY AND SUBCATEGORY PERFORMANCE
---------------------------------------------------------
Analyzes how different product categories and
subcategories contribute to revenue and profitability.
---------------------------------------------------------
*/

WITH category_sales AS (

    SELECT
        category,
        SUM(sales) AS category_sales
    FROM fact_superstore_sales
    GROUP BY category

)

SELECT
    f.category,
    f.sub_category,
    ROUND(SUM(f.sales), 2) AS sub_category_sales,
    ROUND(SUM(f.profit), 2) AS sub_category_profit,
    CAST(
        ROUND(
            SUM(f.profit) / NULLIF(SUM(f.sales), 0),
            4
        ) AS DECIMAL(10,4)
    ) AS sub_category_profit_margin
FROM fact_superstore_sales f
INNER JOIN category_sales c
    ON c.category = f.category
GROUP BY
    f.category,
    f.sub_category,
    c.category_sales
ORDER BY
    c.category_sales DESC,
    sub_category_sales DESC;



/*
---------------------------------------------------------
CUSTOMER SEGMENT ANALYSIS
---------------------------------------------------------
Examines sales and profitability across customer
segments.
---------------------------------------------------------
*/

SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    CAST(
        ROUND(
            SUM(profit) / NULLIF(SUM(sales), 0),
            4
        ) AS DECIMAL(10,4)
    ) AS profit_margin
FROM fact_superstore_sales
GROUP BY
    segment
ORDER BY
    total_sales DESC;



/*
---------------------------------------------------------
LOSS-MAKING PRODUCT AREAS
---------------------------------------------------------
Identifies product categories and subcategories where
overall profit is negative.
---------------------------------------------------------
*/

SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM fact_superstore_sales
GROUP BY
    category,
    sub_category
HAVING
    SUM(profit) < 0
ORDER BY
    total_profit;



/*
---------------------------------------------------------
TOP PROFITABLE PRODUCTS
---------------------------------------------------------
Lists the top 10 products generating the highest profit.
---------------------------------------------------------
*/

SELECT TOP 10
    product_name,
    ROUND(SUM(profit), 2) AS total_profit
FROM fact_superstore_sales
GROUP BY
    product_name
ORDER BY
    total_profit DESC;



/*
---------------------------------------------------------
LEAST PROFITABLE PRODUCTS
---------------------------------------------------------
Identifies the 10 products generating the lowest profit.
---------------------------------------------------------
*/

SELECT TOP 10
    product_name,
    ROUND(SUM(profit), 2) AS total_profit
FROM fact_superstore_sales
GROUP BY
    product_name
ORDER BY
    total_profit ASC;



/*
---------------------------------------------------------
REGIONAL PROFIT TRENDS
---------------------------------------------------------
Analyzes how profitability changes across regions
over time.

Uses the calendar dimension to support consistent
year-based reporting.
---------------------------------------------------------
*/

SELECT
    f.region,
    c.[year],
    ROUND(SUM(f.profit), 2) AS yearly_profit
FROM fact_superstore_sales f
INNER JOIN dim_calendar c
    ON c.calendar_date = f.order_date
GROUP BY
    f.region,
    c.[year]
ORDER BY
    f.region,
    c.[year];



/*
---------------------------------------------------------
DISCOUNT IMPACT ANALYSIS
---------------------------------------------------------
Examines how different discount levels affect
sales performance and profitability.
---------------------------------------------------------
*/

SELECT
    discount,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    CAST(
        ROUND(
            SUM(profit) / NULLIF(SUM(sales), 0),
            4
        ) AS DECIMAL(10,4)
    ) AS profit_margin
FROM fact_superstore_sales
GROUP BY
    discount
ORDER BY
    discount;
