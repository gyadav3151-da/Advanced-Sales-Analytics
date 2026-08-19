/*
===========================================================
TIME SERIES ANALYSIS
===========================================================

Purpose:
- Analyze revenue trends over time.
- Measure cumulative business growth.
- Evaluate month-over-month changes.
- Smooth short-term fluctuations using moving averages.

Methodology:
1. Monthly Revenue Trend
2. Running Monthly Totals
3. Month-over-Month Analysis
4. Three-Month Moving Average

Data Sources:
- fact_superstore_sales
- dim_calendar

===========================================================
*/


/*
---------------------------------------------------------
MONTHLY REVENUE TREND
---------------------------------------------------------
Aggregates monthly sales to reveal long-term trends
and seasonality.
---------------------------------------------------------
*/

WITH monthly_sales AS (

    SELECT
        c.year_month,
        c.year_month_sort,
        SUM(f.sales) AS total_sales

    FROM fact_superstore_sales f
    INNER JOIN dim_calendar c
        ON f.order_date = c.calendar_date

    GROUP BY
        c.year_month,
        c.year_month_sort

)

SELECT
    year_month,
    total_sales

FROM monthly_sales

ORDER BY year_month_sort;



/*
---------------------------------------------------------
RUNNING MONTHLY TOTALS
---------------------------------------------------------
Calculates cumulative revenue over time.

Useful for understanding long-term business growth.
---------------------------------------------------------
*/

WITH monthly_sales AS (

    SELECT
        c.year_month,
        c.year_month_sort,
        SUM(f.sales) AS total_sales

    FROM fact_superstore_sales f
    INNER JOIN dim_calendar c
        ON f.order_date = c.calendar_date

    GROUP BY
        c.year_month,
        c.year_month_sort

)

SELECT
    year_month,
    total_sales,

    SUM(total_sales) OVER (
        ORDER BY year_month_sort
    ) AS running_total

FROM monthly_sales

ORDER BY year_month_sort;



/*
---------------------------------------------------------
MONTH-OVER-MONTH ANALYSIS
---------------------------------------------------------
Compares each month's revenue against the previous
month to measure growth and decline.

LAG() retrieves the previous month's revenue for
comparison.
---------------------------------------------------------
*/

WITH monthly_sales AS (

    SELECT
        c.year_month,
        c.year_month_sort,
        SUM(f.sales) AS total_sales

    FROM fact_superstore_sales f
    INNER JOIN dim_calendar c
        ON f.order_date = c.calendar_date

    GROUP BY
        c.year_month,
        c.year_month_sort

),

monthly_sales_lagged AS (

    SELECT
        year_month,
        year_month_sort,
        total_sales,

        LAG(total_sales) OVER (
            ORDER BY year_month_sort
        ) AS prev_month_sales

    FROM monthly_sales

)

SELECT
    year_month,

    total_sales,

    prev_month_sales,

    total_sales - prev_month_sales AS revenue_change,

    CAST(
        (
            (total_sales - prev_month_sales)
            / prev_month_sales
        ) * 100
        AS DECIMAL(10,2)
    ) AS mom_growth_pct

FROM monthly_sales_lagged

ORDER BY year_month_sort;



/*
---------------------------------------------------------
THREE-MONTH MOVING AVERAGE
---------------------------------------------------------
Smooths short-term fluctuations by averaging the
current month and the previous two months.

Useful for identifying underlying trends while
reducing monthly volatility.
---------------------------------------------------------
*/

WITH monthly_sales AS (

    SELECT
        c.year_month,
        c.year_month_sort,
        SUM(f.sales) AS total_sales

    FROM fact_superstore_sales f
    INNER JOIN dim_calendar c
        ON f.order_date = c.calendar_date

    GROUP BY
        c.year_month,
        c.year_month_sort

)

SELECT
    year_month,

    total_sales,

    CAST(

        AVG(total_sales) OVER (

            ORDER BY year_month_sort

            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW

        )

        AS DECIMAL(12,2)

    ) AS revenue_moving_avg_3m

FROM monthly_sales

ORDER BY year_month_sort;
