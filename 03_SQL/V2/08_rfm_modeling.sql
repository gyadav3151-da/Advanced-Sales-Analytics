/*
===========================================================
CUSTOMER SEGMENTATION MODEL USING RFM
===========================================================

Purpose:
- Build an RFM (Recency, Frequency, Monetary) model
  to evaluate customer behavior.
- Transform transaction-level data into customer-level
  metrics.
- Assign relative scores based on customer rankings.
- Segment customers into meaningful business groups.

Methodology:
1. Calculate raw RFM metrics.
2. Assign relative scores using NTILE().
3. Create composite metrics.
4. Apply business segmentation rules.

Data Source:
- fact_superstore_sales

Output:
- rfm_final

===========================================================
*/


USE AdvancedSalesAnalytics;
GO

CREATE OR ALTER VIEW rfm_final AS

/*
---------------------------------------------------------
STEP 1: CALCULATE RAW RFM METRICS
---------------------------------------------------------
Aggregates transaction-level data into customer-level
metrics.

Metrics:
- Recency: Days since last purchase.
- Frequency: Number of unique orders.
- Monetary: Total customer revenue.
---------------------------------------------------------
*/
WITH rfm_raw_metrics AS (

    SELECT
        customer_id,

        -- Days since customer's most recent purchase
        DATEDIFF(
            DAY,
            MAX(order_date),
            (
                SELECT MAX(order_date)
                FROM fact_superstore_sales
            )
        ) AS recency,

        -- Number of distinct orders
        COUNT(DISTINCT order_id) AS frequency,

        -- Total revenue generated
        SUM(sales) AS monetary

    FROM fact_superstore_sales
    GROUP BY customer_id

),


/*
---------------------------------------------------------
STEP 2: ASSIGN RFM SCORES
---------------------------------------------------------
Ranks customers relative to one another using
quintiles.

Higher scores represent more desirable behavior.
---------------------------------------------------------
*/
rfm_scored AS (

    SELECT
        customer_id,

        -- Raw metrics
        recency,
        frequency,
        monetary,

        -- Relative scoring layer
        (6 - NTILE(5) OVER (
            ORDER BY recency ASC
        )) AS r_score,

        (6 - NTILE(5) OVER (
            ORDER BY frequency DESC
        )) AS f_score,

        (6 - NTILE(5) OVER (
            ORDER BY monetary DESC
        )) AS m_score

    FROM rfm_raw_metrics

),


/*
---------------------------------------------------------
STEP 3: CUSTOMER SEGMENTATION
---------------------------------------------------------
Combines RFM scores and applies business rules to
assign customers into segments.

Segments are intended to reflect customer value,
engagement, and churn risk.
---------------------------------------------------------
*/
rfm_segmentation AS (

    SELECT
        customer_id,

        -- Raw metrics
        recency,
        frequency,
        monetary,

        -- Individual scores
        r_score,
        f_score,
        m_score,

        -- Composite metrics
        CONCAT(
            r_score,
            f_score,
            m_score
        ) AS rfm_score,

        (r_score + f_score + m_score) AS total_score,


        /*
        ---------------------------------------------
        SEGMENTATION RULES
        ---------------------------------------------
        */
        CASE

            -- Highest-value customers
            WHEN r_score = 5
            AND f_score = 5
            AND m_score = 5
            THEN 'Champions'

            -- Previously valuable customers showing
            -- signs of inactivity
            WHEN r_score <= 2
            AND f_score >= 4
            AND m_score >= 4
            THEN 'At Risk - High Value'

            -- Strong spenders with inconsistent
            -- behavior patterns
            WHEN m_score >= 4
            AND (r_score <= 3 AND f_score <= 3)
            THEN 'High Value / Irregular Customers'

            -- Active repeat customers
            WHEN r_score >= 4
            AND f_score >= 4
            THEN 'Loyal Customers'

            -- Recently acquired customers with
            -- promising behavior
            WHEN r_score >= 4
            AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

            -- Weak customers across all dimensions
            WHEN r_score <= 2
            AND f_score <= 2
            AND m_score <= 2
            THEN 'Low Value Customers'

            -- Remaining mid-tier customers
            ELSE 'Core / Regular Customers'

        END AS segment

    FROM rfm_scored

)

SELECT *
FROM rfm_segmentation;
GO
