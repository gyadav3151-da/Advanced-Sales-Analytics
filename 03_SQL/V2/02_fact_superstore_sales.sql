/*
===========================================================
SUPERSTORE SALES - FACT TABLE LOAD
===========================================================

Purpose:
- Creates the fact table if it does not already exist.
- Loads cleaned data from the staging table.
- Performs validation checks to ensure data integrity.

Workflow:
Staging Table
    ↓
Fact Table
    ↓
Validation Checks

===========================================================
*/

USE AdvancedSalesAnalytics;
GO


-- =========================================================
-- FACT TABLE (CREATE IF NOT EXISTS)
-- =========================================================
IF OBJECT_ID('fact_superstore_sales', 'U') IS NULL
BEGIN
    CREATE TABLE fact_superstore_sales (

        -- Order Information
        row_id          INT PRIMARY KEY,
        order_id        VARCHAR(50),

        -- Dates
        order_date      DATE,
        ship_date       DATE,

        -- Shipping
        ship_mode       VARCHAR(50),

        -- Customer Information
        customer_id     VARCHAR(50),
        customer_name   VARCHAR(100),
        segment         VARCHAR(50),

        -- Geographic Information
        country         VARCHAR(100),
        city            VARCHAR(100),
        state           VARCHAR(100),
        postal_code     VARCHAR(20),
        region          VARCHAR(50),

        -- Product Information
        product_id      VARCHAR(50),
        category        VARCHAR(100),
        sub_category    VARCHAR(100),
        product_name    VARCHAR(255),

        -- Measures
        sales           DECIMAL(12,2),
        quantity        INT,
        discount        DECIMAL(5,2),
        profit          DECIMAL(12,2)

    );
END;
GO


-- =========================================================
-- RESET FACT TABLE
-- =========================================================
-- Allows safe reruns of the script without creating
-- duplicate records.
TRUNCATE TABLE fact_superstore_sales;
GO


-- =========================================================
-- LOAD FACT TABLE FROM STAGING
-- =========================================================
INSERT INTO fact_superstore_sales (

    row_id,
    order_id,

    order_date,
    ship_date,

    ship_mode,

    customer_id,
    customer_name,
    segment,

    country,
    city,
    state,
    postal_code,
    region,

    product_id,
    category,
    sub_category,
    product_name,

    sales,
    quantity,
    discount,
    profit
)

SELECT

    CAST(row_id AS INT),
    order_id,

    CAST(order_date AS DATE),
    CAST(ship_date AS DATE),

    ship_mode,

    customer_id,
    customer_name,
    segment,

    country,
    city,
    state,
    postal_code,
    region,

    product_id,
    category,
    sub_category,
    product_name,

    CAST(sales AS DECIMAL(12,2)),
    CAST(quantity AS INT),
    CAST(discount AS DECIMAL(5,2)),
    CAST(profit AS DECIMAL(12,2))

FROM stg_superstore_sales;
GO


/*
---------------------------------------------------------
RECORD COUNT VALIDATION
---------------------------------------------------------
Ensures the number of rows loaded into the fact table
matches the number of rows in the staging table.
---------------------------------------------------------
*/

SELECT
    COUNT(*) AS fact_count
FROM fact_superstore_sales;

SELECT
    COUNT(*) AS staging_count
FROM stg_superstore_sales;



/*
---------------------------------------------------------
NULL VALUE CHECK
---------------------------------------------------------
Identifies rows where type conversion or loading may
have failed, resulting in missing values.
---------------------------------------------------------
*/

SELECT *
FROM fact_superstore_sales
WHERE row_id IS NULL
    OR order_id IS NULL
    OR order_date IS NULL
    OR ship_date IS NULL
    OR ship_mode IS NULL
    OR customer_id IS NULL
    OR customer_name IS NULL
    OR segment IS NULL
    OR country IS NULL
    OR city IS NULL
    OR state IS NULL
    OR postal_code IS NULL
    OR region IS NULL
    OR product_id IS NULL
    OR category IS NULL
    OR sub_category IS NULL
    OR product_name IS NULL
    OR quantity IS NULL
    OR sales IS NULL
    OR discount IS NULL
    OR profit IS NULL;



/*
---------------------------------------------------------
DUPLICATE RECORD CHECK
---------------------------------------------------------
Ensures each transaction line is loaded only once.
Row_ID represents the natural grain of the dataset and
should uniquely identify every record.
---------------------------------------------------------
*/
SELECT
    row_id,
    COUNT(*) AS duplicate_count
FROM fact_superstore_sales
GROUP BY row_id
HAVING COUNT(*) > 1;


/*
---------------------------------------------------------
SAMPLE DATA REVIEW
---------------------------------------------------------
Provides a quick preview of the loaded fact table.
Useful for visual inspection.
---------------------------------------------------------
*/

SELECT TOP 10 *
FROM fact_superstore_sales;
