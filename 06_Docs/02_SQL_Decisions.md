# 2. SQL Decisions

This section documents the key decisions made while designing the SQL Server analytical layer for Advanced Sales Analytics V2.

The objective was to create a SQL layer that is reliable, reusable, and independent from the Power BI presentation layer.

---

## 2.1 Why SQL Server?

### Decision

SQL Server was selected as the central database and analytical modeling platform.

### Why?

The project contains multiple analytical requirements that benefit from a structured relational model, including:

* Transaction-level sales analysis
* Customer-level analysis
* RFM segmentation
* Cohort retention
* Time-series analysis
* Product and regional analysis
* Profitability analysis

SQL Server also provides a clear environment for separating:

```text
Data Storage
    ↓
Data Modeling
    ↓
Analytical Logic
```

This makes the analytical layer reusable outside of Power BI.

---

## 2.2 Why Use a Staging Table?

### Decision

The raw data is first loaded into:

```text
stg_superstore_sales
```

before being inserted into the final fact table.

### Why?

The source CSV contained formatting and data-quality issues that made direct loading into the final analytical table less reliable.

The staging layer provides a controlled intermediate step where data can be:

* Loaded safely
* Inspected
* Validated
* Troubleshot
* Transformed before final insertion

The architecture therefore separates:

```text
Source Data
    ↓
Staging
    ↓
Analytical Model
```

rather than coupling ingestion directly to the final table.

### Trade-off

The additional table introduces another step into the ETL process, but the improved reliability and troubleshooting capability outweigh the small increase in complexity.

---

## 2.3 Why Use a Fact Table?

### Decision

The cleaned data is stored in:

```text
fact_superstore_sales
```

as the central transactional table.

### Why?

A dedicated fact table provides a stable analytical source separate from the raw ingestion layer.

This allows the source dataset to change without requiring downstream analytical logic to operate directly against the raw file structure.

The fact table also provides a consistent foundation for:

* Customer analysis
* Product analysis
* Regional analysis
* Revenue analysis
* Profitability analysis
* Time-series analysis

---

## 2.4 Why Order-Line Grain?

### Decision

The fact table maintains **order-line grain**.

Each row represents an individual product line within an order.

### Why?

Maintaining detailed transactional grain preserves the greatest amount of analytical flexibility.

For example, the same fact table can support:

```text
Order-line analysis
        ↓
Order-level metrics
        ↓
Customer-level metrics
        ↓
Monthly / yearly metrics
```

This allows metrics such as Average Order Value to be calculated by first determining the number of unique orders rather than requiring a separate pre-aggregated order table.

### Trade-off

A lower-grain fact table can require additional aggregation when calculating higher-level metrics.

However, losing transactional detail through premature aggregation would make many future analyses impossible.

Therefore, the project prioritizes **detail preservation over pre-aggregation**.

---

## 2.5 Why a Dedicated Calendar Dimension?

### Decision

A dedicated calendar dimension was created in SQL Server:

```text
dim_calendar
```

rather than relying exclusively on the order date stored in the fact table.

### Why?

Time is a major analytical dimension in the project.

The SQL calendar dimension provides centralized attributes for:

* Calendar Date
* Year
* Month Number
* Month Name
* Year-Month
* Year-Month Sort Key

This provides a consistent time structure for SQL analysis and Power BI reporting.

The calendar dimension supports:

* YoY analysis
* MoM analysis
* Running totals
* Moving averages
* Seasonality analysis
* Cohort analysis
* Chronological sorting

### Fiscal Calendar in Power BI

Fiscal-year attributes were **not added to the SQL calendar table**.

Instead, fiscal-year logic was implemented in Power BI using DAX because it was required for the dashboard's reporting structure and provided an opportunity to apply time-intelligence concepts in DAX.

The Power BI layer therefore extends the SQL calendar dimension with report-specific fiscal attributes, including:

* Fiscal Year Label
* Fiscal Year Month

This creates a deliberate distinction between:

```text
SQL Calendar Dimension
→ Core reusable calendar attributes

Power BI / DAX
→ Report-specific fiscal calendar logic
```

### Why this approach?

The SQL calendar remains a general-purpose calendar dimension, while fiscal logic required specifically by the report is handled in the reporting layer.

This also avoids adding presentation-specific logic to the underlying SQL model when the requirement is primarily driven by the Power BI report.

### Trade-off

Implementing fiscal attributes in DAX means that the SQL layer does not independently contain the fiscal calendar definition.

However, in this project the fiscal calendar was primarily required for Power BI reporting, making the reporting layer an appropriate place for the implementation.

It also allowed the project to demonstrate practical use of DAX time-intelligence concepts rather than moving all time-related logic into SQL.


---

## 2.6 Why Use Analytical Views?

### Decision

Reusable SQL views were created for analytical structures that are consumed by multiple downstream analyses.

### Why?

Some business logic should exist independently of how it is eventually visualized.

For example, customer segmentation should not change depending on whether it is displayed as:

* A table
* A KPI
* A bar chart
* A tooltip

A reusable analytical view provides a consistent source for those downstream uses.

This also reduces duplicated SQL logic and keeps the Power BI model focused on reporting rather than recreating the entire analytical layer.

---

## 2.7 Why Separate Analytical Areas?

### Decision

The SQL layer is organized around distinct analytical areas rather than placing every query into one large analytical script.

The major areas include:

* Customer analysis
* Revenue analysis
* Risk analysis
* RFM analysis
* Cohort analysis
* Time-series analysis
* Business analysis

### Why?

Each analytical area answers a different class of business question.

Separating them makes it easier to:

* Locate relevant logic
* Maintain individual analyses
* Reuse analytical outputs
* Explain the project architecture
* Extend the project later

The separation also mirrors the way the final Power BI report is organized around business questions.

---

## 2.8 Why Use Window Functions?

### Decision

SQL window functions are used for ranking, time-series comparisons, and cumulative calculations.

Examples include:

```text
ROW_NUMBER()
RANK()
DENSE_RANK()
LAG()
SUM() OVER()
AVG() OVER()
```

### Why?

Window functions allow calculations to be performed across related rows while preserving the underlying row-level detail.

They are particularly useful for:

* Ranking products
* Comparing current and previous periods
* Calculating running totals
* Calculating moving averages
* Identifying first purchases
* Supporting customer and cohort analysis

For example, `LAG()` allows a monthly sales value to be compared directly with the previous month without collapsing the dataset into separate intermediate tables.

---

## 2.9 Why RFM Modeling in SQL?

### Decision

RFM metrics and customer segmentation were modeled in SQL.

The RFM process follows:

```text
Customer Transactions
        ↓
RFM Raw Metrics
        ↓
RFM Scores
        ↓
RFM Segmentation
        ↓
Customer Analysis
```

### Why?

RFM is fundamentally a customer-level analytical model rather than a presentation calculation.

The process requires:

* Aggregating transaction data to customer level
* Calculating recency
* Calculating purchase frequency
* Calculating monetary value
* Scoring customers
* Assigning behavioral segments

Performing these transformations in SQL creates a reusable customer-level analytical structure that can be consumed by Power BI.

---

## 2.10 Why NTILE(5) for RFM Scoring?

### Decision

RFM scores are calculated using:

```text
NTILE(5)
```

creating five relative scoring groups.

### Why?

The source dataset does not provide predefined RFM thresholds.

Using quintile-based scoring allows customers to be ranked relative to the rest of the customer population.

The resulting scale is:

```text
1 = Lowest relative score
5 = Highest relative score
```

This provides a consistent framework for combining:

* Recency
* Frequency
* Monetary value

into customer segments.

### Trade-off

Quintile scoring is **relative rather than absolute**.

A customer receiving a score of 5 means that the customer belongs to a high-performing group relative to the analyzed population. It does not mean that the customer has achieved a predefined business threshold.

---

## 2.11 Why Cohort Analysis Uses First Purchase?

### Decision

Customers are grouped into cohorts according to the month of their first purchase.

### Why?

The objective of cohort analysis is to evaluate how customer behavior changes after customers first enter the business.

The analysis therefore follows:

```text
First Purchase
      ↓
Cohort Assignment
      ↓
Subsequent Activity
      ↓
Months Since First Purchase
      ↓
Retention
```

This makes Month 0 the customer's initial purchase period and subsequent months represent the age of the customer relationship.

### Why this matters

A simple monthly customer-count analysis can show whether the overall customer base is growing, but it cannot distinguish between:

* New customers entering the business
* Existing customers returning
* Customers becoming inactive

Cohort analysis provides that additional retention perspective.

---

## 2.12 Why Keep Cohort Logic Separate from RFM?

### Decision

Cohort retention and RFM segmentation are treated as complementary analyses rather than combining them into one model.

### Why?

They answer different questions.

**RFM asks:**

> What type of customer is this based on their historical behavior and value?

**Cohort analysis asks:**

> How well does the business retain customers after their first purchase?

For example, a customer may be classified as a high-value RFM customer while belonging to a cohort with declining long-term retention.

Keeping the analyses separate allows both perspectives to be examined without forcing different analytical concepts into one metric.

---

## 2.13 Why Perform Time-Series Analysis in SQL?

### Decision

The SQL layer contains time-series analysis for monthly sales, running totals, period comparisons, and moving averages.

### Why?

Time-series calculations benefit from SQL window functions and the centralized calendar dimension.

For example:

```text
Monthly Sales
      ↓
LAG()
      ↓
Previous Month Sales
      ↓
MoM Growth
```

and:

```text
Monthly Sales
      ↓
SUM() OVER()
      ↓
Running Total
```

Performing these analytical calculations in SQL also provides a reusable foundation for subsequent Power BI reporting.

---

## 2.14 SQL vs DAX: Where Should the Logic Live?

### Decision

The project does not attempt to place every calculation exclusively in SQL or exclusively in DAX.

Instead, logic is placed according to its purpose.

### SQL is preferred for:

* Data preparation after ingestion
* Customer-level aggregation
* RFM modeling
* Customer segmentation
* Cohort preparation
* Reusable analytical structures
* Transformations that do not depend on report interaction

### DAX is preferred for:

* Filter-context-dependent metrics
* Interactive YoY calculations
* MoM calculations
* Dynamic KPIs
* Dashboard-specific calculations
* Metrics that need to respond dynamically to slicers

### Principle

```text
SQL
→ Build reusable analytical structures

DAX
→ Calculate context-dependent report metrics

Power BI
→ Present and explore the results
```

This prevents the Power BI report from becoming responsible for the entire analytical pipeline while still taking advantage of DAX's ability to respond dynamically to user interaction.

---

# SQL Design Principles

## Reusability

Analytical logic that is likely to be used by multiple reports or analyses should be implemented in reusable SQL structures where appropriate.

---

## Preserve Detail

The fact table retains order-line grain so that higher-level metrics can be derived without permanently losing transactional detail.

---

## Separate Ingestion from Analysis

The staging layer isolates source-data issues from the analytical model.

---

## Minimize Duplication

Reusable views and centralized dimensions reduce the need to repeat the same transformations across individual analytical queries.

---

## Keep Business Logic Transparent

SQL transformations are structured so that the path from transactional data to analytical output can be traced and understood.

---

# Outcome

The SQL layer provides a reusable analytical foundation for the Power BI report while remaining independently queryable.

The resulting flow is:

```text
Raw Data
   ↓
Staging
   ↓
Fact Table
   ↓
Dimensions
   ↓
Analytical Models
   ↓
Power BI / DAX
```

This architecture allows the project to demonstrate not only SQL querying ability, but also decisions around **data modeling, analytical design, reusability, and separation of responsibilities**.
