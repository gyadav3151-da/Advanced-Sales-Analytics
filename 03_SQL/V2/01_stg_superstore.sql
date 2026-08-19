/*
===========================================================
SUPERSTORE SALES - VALIDATION & STAGING LOAD
===========================================================
Purpose:
- Creates staging table if not exists
- Loads raw data
- Runs data quality checks

Changes from V1:
- Improved the ingestion pipeline through cleaner
  source data preparation in Python.
- Updated BULK INSERT specifications to improve
  loading reliability and data consistency.
- Added safe rerun capability using TRUNCATE TABLE.
- Preserved row_id to maintain transaction uniqueness.
- Established the foundation for a layered
  architecture (staging → fact → analytics).

Data Source: v2_superstore_clean.csv
===========================================================
*/


-- =========================================================
-- DATABASE CREATION/SELECTION
-- =========================================================
IF DB_ID('AdvancedSalesAnalytics') IS NULL
BEGIN
    CREATE DATABASE AdvancedSalesAnalytics;
END;
GO

USE AdvancedSalesAnalytics;
GO


-- =========================================================
-- STAGING TABLE (AUTO-CREATE)
-- =========================================================
IF OBJECT_ID('stg_superstore_sales', 'U') IS NULL
BEGIN
    CREATE TABLE stg_superstore_sales (
        row_id          VARCHAR(50),
        order_id        VARCHAR(50),

        order_date      VARCHAR(20),
        ship_date       VARCHAR(20),

        ship_mode       VARCHAR(50),

        customer_id     VARCHAR(50),
        customer_name   VARCHAR(100),
        segment         VARCHAR(50),

        country         VARCHAR(50),
        city            VARCHAR(100),
        state           VARCHAR(50),
        postal_code     VARCHAR(20),
        region          VARCHAR(50),

        product_id      VARCHAR(50),
        category        VARCHAR(50),
        sub_category    VARCHAR(50),
        product_name    VARCHAR(255),

        sales           FLOAT,
        quantity        INT,
        discount        FLOAT,
        profit          FLOAT
    );
END;


-- =========================================================
-- CLEAR STAGING (SAFE FOR RERUNS)
-- =========================================================
TRUNCATE TABLE stg_superstore_sales;


-- =========================================================
-- LOAD DATA INTO STAGING
-- Update this path to the location of the cloned repository
-- =========================================================
BULK INSERT stg_superstore_sales
FROM '<PATH_TO_DATASET>/v2_superstore_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);


-- =========================================================
-- VALIDATION: ROW COUNT CHECK
-- =========================================================
SELECT COUNT(*) AS total_records
FROM stg_superstore_sales;


-- =========================================================
-- VALIDATION: NULL CHECK (CRITICAL FIELDS)
-- =========================================================
SELECT *
FROM stg_superstore_sales
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


-- =========================================================
-- VALIDATION: DATA TYPE CHECK
-- =========================================================
SELECT *
FROM stg_superstore_sales
WHERE TRY_CAST(quantity AS INT) IS NULL
  AND quantity IS NOT NULL;


-- =========================================================
-- OPTIONAL: SAMPLE REVIEW
-- =========================================================
SELECT TOP 100 *
FROM stg_superstore_sales;
