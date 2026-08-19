/*
===========================================================
CUSTOMER SEGMENT ANALYSIS USING RFM
===========================================================

Purpose:
- Analyze customer behavior using Recency,
  Frequency, and Monetary (RFM) metrics.
- Compare customer segments across engagement
  and revenue contribution.
- Quantify business exposure from high-value
  customers at risk of churn.

Methodology:
1. Customer Overview
2. Revenue Overview
3. Risk Analysis

Data Source:
- rfm_final

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
CUSTOMER OVERVIEW
---------------------------------------------------------
Provides a high-level summary of customer segments.

Metrics:
- Number of customers
- Percentage of customers
- Average recency
- Average purchase frequency

Useful for understanding the composition and
engagement patterns of the customer base.
---------------------------------------------------------
*/

SELECT
    segment,

    COUNT(*) AS customer_count,

    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)
    ) AS customer_pct,

    AVG(recency) AS avg_recency,

    AVG(frequency) AS avg_frequency

FROM rfm_final
GROUP BY segment;



/*
---------------------------------------------------------
REVENUE OVERVIEW
---------------------------------------------------------
Measures how revenue is distributed across customer
segments.

Metrics:
- Total revenue
- Percentage of total revenue
- Revenue per customer
- Average order value

Useful for identifying which segments contribute
the greatest economic value.
---------------------------------------------------------
*/

WITH segment_agg AS (

    SELECT
        segment,
        SUM(monetary) AS total_revenue,
        COUNT(customer_id) AS customer_count,
        SUM(frequency) AS total_orders

    FROM rfm_final
    GROUP BY segment

)

SELECT
    segment,

    total_revenue,

    CAST(
        total_revenue * 100.0
        / SUM(total_revenue) OVER ()
        AS DECIMAL(5,2)
    ) AS revenue_pct,

    CAST(
        total_revenue
        / NULLIF(customer_count, 0)
        AS DECIMAL(12,2)
    ) AS revenue_per_customer,

    CAST(
        total_revenue
        / NULLIF(total_orders, 0)
        AS DECIMAL(12,2)
    ) AS avg_order_value

FROM segment_agg;



/*
---------------------------------------------------------
RISK ANALYSIS
---------------------------------------------------------
Quantifies the business impact associated with
high-value customers who are at risk of churn.

Metrics:
- Customer exposure
- Percentage of customers exposed
- Revenue exposure
- Percentage of revenue exposed

Useful for assessing the potential impact of
customer attrition.
---------------------------------------------------------
*/

WITH business_agg AS (

    SELECT
        COUNT(customer_id) AS total_customer_count,
        SUM(monetary) AS total_revenue

    FROM rfm_final

),

at_risk_agg AS (

    SELECT
        segment,
        SUM(monetary) AS revenue_exposure,
        COUNT(customer_id) AS customer_exposure

    FROM rfm_final
    WHERE segment = 'At Risk - High Value'

    GROUP BY segment

)

SELECT
    segment,

    customer_exposure,

    CAST(
        customer_exposure * 100.0
        / NULLIF(total_customer_count, 0)
        AS DECIMAL(5,2)
    ) AS customer_exposure_pct,

    revenue_exposure,

    CAST(
        revenue_exposure * 100.0
        / NULLIF(total_revenue, 0)
        AS DECIMAL(5,2)
    ) AS revenue_exposure_pct

FROM at_risk_agg
CROSS JOIN business_agg;
