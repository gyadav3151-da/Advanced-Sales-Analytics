# 1. Architecture

## Overview

Advanced Sales Analytics V2 follows a layered analytics architecture that separates **data preparation, data modeling, analytical logic, visualization, and business interpretation**.

The architecture evolved from the original Sales Performance & Growth Analysis project. V2 expands the analytical layer to support customer segmentation, RFM analysis, cohort retention, growth analysis, risk analysis, and revenue opportunity analysis.

The goal is to create a workflow that is:

* Maintainable
* Reusable
* Transparent
* Separated by responsibility
* Suitable for both technical analysis and business reporting

---

## Data Flow

```text
Raw Dataset (CSV)
        │
        ▼
Python Cleaning & Preparation
        │
        ▼
stg_superstore_sales
(Staging Layer)
        │
        ▼
fact_superstore_sales
(Fact Table)
        │
        ├──────────────► dim_calendar
        │                    (Date Dimension)
        │
        ▼
SQL Analytical Layer
        │
        ├── Business Analysis
        ├── Time Series Analysis
        ├── Cohort Retention
        ├── RFM Modeling
        ├── Customer Segmentation
        └── Analytical Views
        │
        ▼
Power BI / DAX Layer
        │
        ├── Growth Metrics
        ├── Profitability Metrics
        ├── Customer KPIs
        ├── Risk & Opportunity KPIs
        └── Time Intelligence
        │
        ▼
Power BI Dashboard
        │
        ▼
Business Insights & Recommendations
```

---

# Layers

## 1. Raw Dataset

The project begins with the Superstore sales dataset stored as a CSV file.

### Purpose

* Provide the source transactional data.
* Serve as the input to the preprocessing workflow.
* Preserve the original source structure before transformation.

The raw dataset is treated as the source of truth for the analytical workflow.

---

## 2. Python Data Preparation Layer

Python is used to prepare the raw dataset before ingestion into SQL Server.

### Responsibilities

* Handle source formatting issues.
* Standardize column names.
* Validate and prepare data types.
* Convert dates into SQL-compatible formats.
* Resolve CSV quoting and formatting issues.
* Produce a consistent SQL-ready dataset.

### Design Principle

Python is intentionally used for **data preparation**, rather than embedding source-cleaning logic inside Power BI.

This keeps source-specific cleaning separate from downstream analytical logic.

---

## 3. Staging Layer

Table:

```text
stg_superstore_sales
```

The staging table acts as an intermediate landing area between the prepared source file and the analytical fact table.

### Responsibilities

* Safely ingest the prepared dataset.
* Preserve the incoming structure during validation.
* Support troubleshooting and data-quality checks.
* Provide an intermediate step before loading the final fact table.

### Why a staging layer?

Directly loading external data into the final analytical table would couple ingestion and modeling too tightly.

The staging layer provides a controlled boundary between **source data and the analytical model**.

---

## 4. Fact Table

Table:

```text
fact_superstore_sales
```

The fact table is the central transactional table used throughout the analytical model.

### Grain

The fact table operates at **order-line grain**, meaning each row represents an individual product line within an order.

### Responsibilities

* Store transaction-level sales records.
* Preserve detailed product and customer information.
* Provide the central source for downstream analysis.

Measures include:

* Sales
* Quantity
* Discount
* Profit

Maintaining transaction-level grain allows higher-level metrics such as orders, customers, AOV, and customer revenue to be derived without losing underlying detail.

---

## 5. Calendar Dimension

Table:

```text
dim_calendar
```

A dedicated calendar dimension provides a centralized time structure for the analytical model.

### Attributes include

* Calendar Date
* Year
* Month Number
* Month Name
* Year-Month
* Year-Month Sort Key

### Purpose

The calendar dimension supports:

* YoY analysis
* MoM analysis
* Running totals
* Moving averages
* Seasonality analysis
* Cohort analysis
* Power BI time intelligence

Using a dedicated date dimension also prevents time calculations from being dependent on individual transactional date fields.

---

# 6. SQL Analytical Layer

The SQL analytical layer contains reusable analytical structures and queries designed around specific business questions.

SQL is used where logic benefits from being **reusable, structured, and independent of the Power BI presentation layer**.

---

## Business Analysis

Provides analysis of:

* Sales performance
* Profitability
* Regional performance
* Product performance
* Customer segments

The objective is to establish the core business performance metrics used by downstream reporting.

---

## Window Functions & Exploratory Analysis

Advanced SQL functionality is used to analyze and rank business performance.

Examples include:

* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`
* `LAG()`
* `SUM() OVER()`
* `AVG() OVER()`

These techniques support ranking, comparisons, running totals, and time-series analysis.

---

## Time Series Analysis

Examines the behavior of sales across time.

Analysis includes:

* Monthly sales
* Running totals
* Month-over-month growth
* Moving averages
* Year-over-year comparisons

The calendar dimension and window functions are used to maintain chronological consistency.

---

## Cohort Retention Analysis

Cohort analysis evaluates customer retention based on the month of a customer's first purchase.

The process involves:

1. Identifying each customer's first purchase.
2. Assigning customers to a first-purchase cohort.
3. Tracking subsequent customer activity.
4. Calculating months since first purchase.
5. Calculating cohort retention rates.

This analysis provides a customer-centric view of retention that complements the RFM segmentation analysis.

---

## RFM Modeling

RFM analysis evaluates customers using:

* Recency
* Frequency
* Monetary value

The modeling process follows:

```text
rfm_raw_metrics
        │
        ▼
rfm_scored
        │
        ▼
rfm_segmentation
        │
        ▼
rfm_final
```

RFM scoring uses:

```text
NTILE(5)
```

to rank customers across the three dimensions.

The final segmentation is used to support:

* Customer analysis
* Revenue analysis
* Risk analysis
* Opportunity analysis

---

## Customer Segmentation

The final RFM output is used to classify customers into behavioral segments such as:

* Champions
* Loyal Customers
* Potential Loyalists
* Core / Regular Customers
* At Risk - High Value
* High Value / Irregular Customers
* Low Value Customers

The purpose is to move beyond simply measuring customer revenue and instead understand the **quality and behavior of the customer base**.

---

# 7. Power BI & DAX Analytical Layer

Power BI is not used solely as a visualization tool.

The report contains a dedicated DAX layer for calculations that depend on **filter context, time intelligence, and interactive report behavior**.

### Examples include

* YoY Sales Growth
* YoY Customer Growth
* MoM Sales Growth
* CAGR
* Months with Growth
* Average Order Value
* Category YoY Growth
* Category YoY Profit Growth
* Revenue At Risk
* Revenue Opportunity
* Dynamic data-range indicators

### Why DAX?

These calculations depend heavily on the user's current filter context and are therefore better suited to the semantic/reporting layer than static SQL outputs.

This creates a distinction between:

```text
SQL
→ Reusable analytical structures

DAX
→ Context-dependent business metrics

Power BI
→ Interactive presentation
```

---

# 8. Visualization Layer

Power BI provides the interactive reporting layer.

The dashboard is organized around distinct business questions rather than simply grouping visuals by technical dataset structure.

### Dashboard areas include

* Executive Overview
* Customer Analysis
* Product & Geographic Performance
* Growth & Trends

The report includes:

* KPI cards
* Time-series charts
* RFM analysis
* Cohort retention matrix
* Product and regional analysis
* Growth metrics
* Risk and opportunity indicators
* Interactive filtering
* Tooltips
* Bookmark-based navigation

The dashboard is designed to move from **business performance → customer behavior → product/geographic performance → growth and risk**.

---

# 9. Business Interpretation Layer

The final layer translates analytical results into business insights and potential actions.

The project intentionally separates:

```text
Facts
   ↓
Metrics
   ↓
Interpretation
   ↓
Recommendations
```

The dashboard is therefore not intended to simply report numbers.

Examples of business questions addressed include:

* Is revenue growing?
* Which categories drive sales and profit?
* Which customers generate the most value?
* Are valuable customers behaving inconsistently?
* How well are customer cohorts being retained?
* Where does revenue appear exposed to customer risk?
* Where may customer engagement represent an opportunity?
* Which periods demonstrate stronger or weaker performance?

---

# Design Principles

## Separation of Concerns

Data preparation, modeling, analytical logic, visualization, and interpretation are separated into distinct layers.

Each technology is therefore used for the type of work it is best suited to perform.

---

## Reusability

Reusable structures such as the fact table, calendar dimension, RFM model, and analytical views are designed to support multiple analyses rather than a single dashboard visual.

---

## Facts Before Interpretation

The analytical layers are responsible for producing reliable and reusable metrics.

Interpretation and recommendations are intentionally separated from the underlying calculations.

---

## Appropriate Placement of Logic

Logic is placed in the layer where it provides the greatest value:

```text
Python
→ Source preparation

SQL Server
→ Data modeling and reusable analytical logic

DAX
→ Interactive and filter-context-dependent metrics

Power BI
→ Visualization and user interaction

Business Analysis
→ Interpretation and recommendations
```

---

# Architectural Outcome

The final architecture provides a clear separation between **data engineering, analytical modeling, reporting, and business interpretation**.

This structure also makes the project easier to extend.

The architecture was designed as a foundation that can support further analytical development without requiring the core ingestion and modeling layers to be redesigned.
