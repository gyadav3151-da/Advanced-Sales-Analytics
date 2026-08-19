/*
===========================================================
SUPERSTORE SALES V2 - WINDOW FUNCTIONS & EDA
===========================================================

Purpose:
- Explore ranking and partitioning techniques using
  SQL window functions.
- Identify top-performing products across categories
  and regions.
- Compare different ranking functions and their
  behavior.

Data Source:
fact_superstore_sales

===========================================================
*/


/*
---------------------------------------------------------
SELECT DATABASE
---------------------------------------------------------
Uses the project database containing the staging,
fact, and supporting tables.
---------------------------------------------------------
*/

USE AdvancedSalesAnalytics;
GO


/*
---------------------------------------------------------
BLOCK A: PRODUCT RANKING WITHIN CATEGORY
---------------------------------------------------------
Ranks products by total sales within each category.

DENSE_RANK() assigns the same rank to ties and
does not skip subsequent ranks.

Useful for identifying the top-selling products
within each product category.
---------------------------------------------------------
*/

WITH product_sales AS (

    SELECT
        category,
        product_name,
        SUM(sales) AS total_product_sales
    FROM fact_superstore_sales
    GROUP BY
        category,
        product_name

)

SELECT
    category,
    product_name,
    total_product_sales,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY total_product_sales DESC
    ) AS rn
FROM product_sales;



/*
---------------------------------------------------------
BLOCK B: TOP PRODUCT BY REGION
---------------------------------------------------------
Identifies the highest-selling product within each
region.

ROW_NUMBER() guarantees a single winner per region.
When ties occur, product_name is used as a secondary
sorting criterion to ensure deterministic results.
---------------------------------------------------------
*/

WITH product_sales AS (

    SELECT
        region,
        product_name,
        SUM(sales) AS total_sales
    FROM fact_superstore_sales
    GROUP BY
        region,
        product_name

)

SELECT
    region,
    product_name,
    total_sales
FROM (

    SELECT
        region,
        product_name,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY
                total_sales DESC,
                product_name
        ) AS rn
    FROM product_sales

) t
WHERE rn = 1;



/*
---------------------------------------------------------
BLOCK C: COMPLETE PRODUCT RANKING VIEW
---------------------------------------------------------
Displays all products ranked by sales within each
category.

Unlike Block B, no filtering is applied, allowing
the complete ranking hierarchy to be examined.
---------------------------------------------------------
*/

WITH product_sales AS (

    SELECT
        category,
        product_name,
        SUM(sales) AS total_sales
    FROM fact_superstore_sales
    GROUP BY
        category,
        product_name

)

SELECT
    category,
    product_name,
    total_sales,
    DENSE_RANK() OVER (
        PARTITION BY category
        ORDER BY total_sales DESC
    ) AS rn
FROM product_sales;
