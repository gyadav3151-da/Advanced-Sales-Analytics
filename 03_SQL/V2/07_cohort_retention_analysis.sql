/*
===========================================================
SUPERSTORE SALES V2 - COHORT RETENTION ANALYSIS
===========================================================

Purpose:
- Measure customer retention over time.
- Group customers into cohorts based on their
  first purchase month.
- Track how many customers return in subsequent
  months.
- Calculate retention percentages for each cohort.

Methodology:
1. Identify each customer's first purchase date.
2. Assign customers to a cohort month.
3. Track future purchase activity.
4. Count retained customers by month number.
5. Calculate retention percentages.

Data Sources:
- fact_superstore_sales
- dim_calendar

===========================================================
*/

USE AdvancedSalesAnalytics;
GO

/*
---------------------------------------------------------
STEP 1: IDENTIFY CUSTOMER'S FIRST PURCHASE
---------------------------------------------------------
Assigns a row number to each order within a customer.

The earliest order (rn = 1) represents the customer's
first purchase and determines the cohort to which
they belong.
---------------------------------------------------------
*/

CREATE OR ALTER VIEW vw_cohort_retention AS

WITH order_date_ranked AS (

    SELECT
        customer_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS rn
    FROM fact_superstore_sales

),


/*
---------------------------------------------------------
STEP 2: ASSIGN CUSTOMERS TO COHORTS
---------------------------------------------------------
Maps each customer's first purchase date to a
cohort month using the calendar dimension.

The numeric sort key is retained to support
chronological sorting in reporting tools such
as Power BI.
---------------------------------------------------------
*/

first_purchase_cohort AS (

    SELECT
        o.customer_id,
        o.order_date,
        c.year_month AS cohort_month,
        c.year_month_sort AS cohort_month_sort
    FROM order_date_ranked o
    INNER JOIN dim_calendar c
        ON o.order_date = c.calendar_date
    WHERE rn = 1

),


/*
---------------------------------------------------------
STEP 3: TRACK CUSTOMER PURCHASE ACTIVITY
---------------------------------------------------------
Associates every customer transaction to the customer's
cohort and calculates how many months have elapsed
since the first purchase.

The purchase month sort key is preserved for
downstream visualization and reporting.
---------------------------------------------------------
*/

customer_cohort_activity AS (

    SELECT
        f.customer_id,
        f.cohort_month,
        c.year_month AS purchase_month,
        c.year_month_sort AS purchase_month_sort,

        DATEDIFF(
            MONTH,
            f.order_date,
            s.order_date
        ) AS month_number

    FROM fact_superstore_sales s
    INNER JOIN first_purchase_cohort f
        ON s.customer_id = f.customer_id
    INNER JOIN dim_calendar c
        ON s.order_date = c.calendar_date

),


/*
---------------------------------------------------------
STEP 4: CALCULATE RETAINED CUSTOMERS
---------------------------------------------------------
Counts how many unique customers from each cohort
return after 0, 1, 2, ... months.
---------------------------------------------------------
*/

cohort_retention AS (

    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM customer_cohort_activity
    GROUP BY
        cohort_month,
        month_number

)


/*
---------------------------------------------------------
FINAL OUTPUT
---------------------------------------------------------
Computes:

- Retained customers
- Original cohort size
- Retention percentage

FIRST_VALUE() retrieves the size of the cohort
(month 0), which serves as the denominator for
retention calculations.
---------------------------------------------------------
*/

SELECT
    cohort_month,
    month_number,
    retained_customers,

    FIRST_VALUE(retained_customers) OVER (
        PARTITION BY cohort_month
        ORDER BY month_number
    ) AS cohort_size,

    CAST(
        CAST(retained_customers AS DECIMAL(12,2))
        /
        FIRST_VALUE(retained_customers) OVER (
            PARTITION BY cohort_month
            ORDER BY month_number
        )
        * 100
    AS DECIMAL(12,2)) AS retention_pct

FROM cohort_retention;
GO

/*
---------------------------------------------------------
PREVIEW
---------------------------------------------------------
*/
SELECT *
FROM vw_cohort_retention;
