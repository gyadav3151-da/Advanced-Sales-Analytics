-- Sales Performance & Growth Analysis
-- Author: Gaurav Yadav
-- Description: SQL scripts used for creating calendar table for further grouping

/* 
==================================================
CALENDAR TABLE CREATION
==================================================
Creates a calendar (date dimension) table used for
time-based analysis in the sales dataset.

This table provides additional attributes such as:
- Year
- Month number
- Month name
- Year-Month format for reporting
- Year-Month sort key for proper chronological sorting

Using a calendar table ensures continuous dates
without gaps and improves time-series analysis in
SQL and Power BI.
*/


/*
--------------------------------------------------
SELECTING DATABASE
--------------------------------------------------
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
REMOVE EXISTING CALENDAR TABLE
--------------------------------------------------
Drops the table if it already exists so the script
can be re-run safely.
*/
DROP TABLE IF EXISTS Calendar;


/*
--------------------------------------------------
GENERATE CALENDAR TABLE
--------------------------------------------------
Creates a sequence of dates starting from
2014-01-01 and ending at the latest order or
shipping date in the dataset.

Dates are generated using the system table
master..spt_values which contains a sequence
of numbers that can be used to generate rows.
*/
SELECT
     /* Base date for each calendar row */
    DATEADD(DAY, number, '2014-01-01') AS Calendar_Date,

     /* Extract year from the generated date */
    YEAR(DATEADD(DAY, number, '2014-01-01')) AS Year,

     /* Numeric month (1–12) */
    MONTH(DATEADD(DAY, number, '2014-01-01')) AS Month_Number,

     /* Full month name (January, February, etc.) */
    DATENAME(MONTH, DATEADD(DAY, number, '2014-01-01')) AS Month_Name,

     /* Month-Year label used for reporting */
    FORMAT(DATEADD(DAY, number, '2014-01-01'),'MMM yyyy') AS YearMonth,

    /*
    Numeric YearMonth key used for sorting
    Example: 201601 = Jan 2016
    This prevents alphabetical sorting issues in BI tools
    */
    YEAR(DATEADD(DAY, number, '2014-01-01'))*100 + MONTH(DATEADD(DAY, number, '2014-01-01')) AS YearMonth_Sort

/* Create the Calendar table */
INTO Calendar

/* Generate rows using system numbers table */
FROM master..spt_values

/* Only use rows representing numbers */
WHERE type = 'P'

/*
Limit generated dates to the maximum date
present in the sales dataset.
*/
AND DATEADD(DAY, number, '2014-01-01')
    <= (SELECT MAX(Order_Date) FROM Superstore_sales) 
AND DATEADD(DAY, number, '2014-01-01')
    <= (SELECT MAX(Ship_Date) FROM Superstore_sales)
;


/*
--------------------------------------------------
VERIFY CALENDAR TABLE
--------------------------------------------------
Displays the generated calendar table.
*/
SELECT * 
FROM Calendar;
