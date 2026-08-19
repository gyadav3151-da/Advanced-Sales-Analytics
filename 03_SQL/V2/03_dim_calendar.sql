/*
===========================================================
SUPERSTORE SALES V2 - CALENDAR TABLE
===========================================================

Purpose:
- Creates a reusable calendar table for time-based
  analysis.
- Extends the V1 project by separating date attributes
  from analytical queries.
- Supports consistent reporting across SQL queries
  and Power BI visualizations.

Improvements Over V1:
- Centralizes date logic instead of repeatedly using
  YEAR() and MONTH() inside analysis queries.
- Provides a reusable time dimension for future
  analysis and dashboards.
- Ensures continuous dates without gaps.
- Improves maintainability and readability.

Attributes Included:
- Calendar Date
- Year
- Quarter
- Month Number
- Month Name
- Day Name
- Year-Month Label
- Year-Month Sort Key

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
REMOVE EXISTING CALENDAR TABLE
---------------------------------------------------------
Drops the existing table to allow safe reruns and
ensure the calendar remains synchronized with the
latest data loaded into the fact table.
---------------------------------------------------------
*/

DROP TABLE IF EXISTS dim_calendar;


/*
---------------------------------------------------------
GENERATE CALENDAR TABLE
---------------------------------------------------------
Creates a continuous sequence of dates beginning on
2014-01-01 and ending at the latest date found in
the fact table.

Unlike V1, which extracted date components directly
inside each analysis query, V2 centralizes these
attributes into a reusable table.

Dates are generated using the SQL Server system
table master..spt_values, which provides a sequence
of integers that can be transformed into dates using
DATEADD().
---------------------------------------------------------
*/

SELECT

    /* Base date */
    DATEADD(DAY, number, '2014-01-01') AS calendar_date,

    /* Calendar year */
    YEAR(
        DATEADD(DAY, number, '2014-01-01')
    ) AS [year],

    /* Quarter number */
    DATEPART(
        QUARTER,
        DATEADD(DAY, number, '2014-01-01')
    ) AS quarter,

    /* Numeric month */
    MONTH(
        DATEADD(DAY, number, '2014-01-01')
    ) AS month_number,

    /* Full month name */
    DATENAME(
        MONTH,
        DATEADD(DAY, number, '2014-01-01')
    ) AS month_name,

    /* Day name */
    DATENAME(
        WEEKDAY,
        DATEADD(DAY, number, '2014-01-01')
    ) AS day_name,

    /*
    Reporting label.

    Example:
    Jan 2016
    */
    FORMAT(
        DATEADD(DAY, number, '2014-01-01'),
        'MMM yyyy'
    ) AS year_month,

    /*
    Sorting key.

    Example:
    Jan 2016 → 201601

    Prevents alphabetical sorting issues in
    reporting tools such as Power BI.
    */
    YEAR(
        DATEADD(DAY, number, '2014-01-01')
    ) * 100
    +
    MONTH(
        DATEADD(DAY, number, '2014-01-01')
    ) AS year_month_sort

INTO dim_calendar

FROM master..spt_values

/*
Only rows representing numeric values are used.
*/
WHERE type = 'P'

/*
Limits the calendar to the latest available date
present in the fact table.

The larger of order_date and ship_date is used
to ensure complete coverage.
*/
AND DATEADD(DAY, number, '2014-01-01')
    <= (
        SELECT
            CASE
                WHEN MAX(ship_date) > MAX(order_date)
                    THEN MAX(ship_date)
                ELSE MAX(order_date)
            END
        FROM fact_superstore_sales
    );


/*
---------------------------------------------------------
VERIFY CALENDAR TABLE
---------------------------------------------------------
Displays the generated calendar table.

This table will be used throughout V2 analysis to
provide consistent and reusable date attributes.
---------------------------------------------------------
*/

SELECT *
FROM dim_calendar;
