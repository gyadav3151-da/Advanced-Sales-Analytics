# 3. Power BI & DAX Decisions

This section documents the key decisions made while developing the Power BI reporting and DAX layer for Advanced Sales Analytics V2.

The primary objective was to use Power BI for **interactive analysis and presentation**, while keeping report-specific calculations responsive to filter context.

---

## 3.1 Why Power BI?

### Decision

Power BI was selected as the visualization and reporting platform.

### Why?

The project requires users to interactively explore performance across multiple dimensions, including:

* Time
* Region
* Category
* Sub-category
* Customer
* RFM segment

Power BI provides:

* Interactive filtering
* Cross-filtering between visuals
* Dynamic measures
* Time-intelligence calculations
* KPI cards
* Drill-down capabilities
* Tooltips
* Bookmark-based navigation

This makes it suitable for turning the underlying SQL analysis into an interactive business-reporting experience.

---

## 3.2 Why Use Measures Instead of Calculated Columns for KPIs?

### Decision

Dynamic business KPIs were generally implemented as **DAX measures** rather than calculated columns.

Examples include:

* Total Sales
* Total Profit
* Profit Margin
* YoY Sales Growth
* MoM Growth
* CAGR
* AOV
* YoY Customer Growth
* Revenue At Risk
* Revenue Opportunity

### Why?

Measures are evaluated within the current filter context.

For example, the same YoY Sales Growth measure can dynamically respond to:

* Selected year
* Region
* Category
* Customer segment
* Other report filters

A calculated column would calculate a value once for each row and would not provide the same dynamic behavior.

### Principle

```text id="9q9ylk"
Calculated Column
→ Row-level / static attributes

Measure
→ Dynamic analytical result
```

---

## 3.3 Why Use the Calendar Dimension for Time Intelligence?

### Decision

Power BI time-intelligence calculations use the dedicated calendar dimension rather than the transactional date directly.

### Why?

The calendar dimension provides a continuous and consistent time structure.

This allows measures using functions such as:

```text id="1j7e7y"
SAMEPERIODLASTYEAR()
DATEADD()
```

to operate consistently across the report.

This was particularly important for:

* YoY Sales Growth
* YoY Customer Growth
* MoM Growth
* Running totals
* Seasonal analysis

Using the dedicated calendar relationship also prevents time-intelligence calculations from becoming dependent on the current selection of transactional rows.

---

## 3.4 Why Implement Fiscal Year Logic in DAX?

### Decision

Fiscal Year and Fiscal Year Month were implemented in the Power BI layer rather than added to the SQL calendar table.

### Why?

Fiscal reporting was a requirement of the Power BI dashboard.

The fiscal attributes were therefore added to the calendar model using DAX:

```text id="h6x7ud"
Fiscal Year Label
Fiscal Year Month
```

This allowed the report to use fiscal periods for:

* Sales trends
* YoY comparisons
* Growth KPIs
* Cohort presentation
* Dashboard filtering

It also provided an opportunity to apply DAX-based time-intelligence concepts within the reporting layer.

### Architectural distinction

```text id="jap1sv"
SQL Calendar
→ General calendar structure

DAX Calendar Extensions
→ Report-specific fiscal structure
```

---

## 3.5 Why Separate Business Logic from Visuals?

### Decision

Business calculations were implemented as reusable DAX measures rather than embedding calculations directly into individual visuals.

### Why?

A reusable measure can support multiple report elements.

For example:

```text id="j0j7b5"
[Total Sales]
      │
      ├── KPI Card
      ├── Sales Trend
      ├── Regional Chart
      ├── Product Chart
      └── Tooltip
```

This reduces duplicated calculations and ensures that different visuals use the same underlying definition.

It also makes the report easier to maintain.

---

# 3.6 Executive Overview Design

### Decision

The first dashboard page focuses on high-level business performance rather than detailed customer or product analysis.

### Why?

The executive page is intended to answer:

> **How is the business performing overall?**

Therefore, it prioritizes:

* Total Sales
* Total Profit
* Profit Margin
* YoY Sales Growth
* Sales trends
* Regional performance
* Category performance
* High-level business context

Detailed customer segmentation and retention analysis are intentionally moved to later pages.

### Design principle

The first page should establish the overall state of the business before the user moves into diagnostic analysis.

---

# 3.7 Customer Analysis Design

### Decision

Customer analysis was given a dedicated dashboard page rather than being combined with the executive overview.

### Why?

Customer behavior requires a different analytical perspective from overall business performance.

The page combines:

* Customer KPIs
* RFM segmentation
* RFM score analysis
* Cohort retention
* Customer contribution analysis

This allows the user to move from:

```text id="j47p3r"
Who are our customers?
        ↓
How valuable are they?
        ↓
How do they behave?
        ↓
Are we retaining them?
```

---

## 3.8 RFM Visualization Design

### Decision

The RFM segment comparison uses **average RFM scores** rather than an indexed score.

### Why?

An indexed visualization could show that one segment has a high or low relative value, but it does not immediately communicate *why* the segment received that classification.

Showing the three underlying RFM dimensions provides more context:

```text id="h0xq9b"
Recency
Frequency
Monetary
```

This allows a user to immediately understand the behavioral profile of each segment.

For example, a segment with:

```text id="fj7b2u"
High Recency
High Frequency
High Monetary
```

has a fundamentally different profile from one with:

```text id="5v4rj8"
Low Recency
Low Frequency
Low Monetary
```

### Design principle

The visualization should expose the underlying analytical dimensions rather than only displaying the resulting segment classification.

---

# 3.9 RFM Snapshot and Date Filtering

### Decision

The RFM segmentation is treated as an **FY2018 point-in-time snapshot** rather than a time-varying metric.

The RFM model uses customer behavior up to the end of FY2018 to calculate:

* Recency
* Frequency
* Monetary value
* RFM scores
* Customer segments

### Why?

RFM is intended to answer:

> **What was the customer's behavioral and value status at the end of the available analysis period?**

It is not intended to answer:

> **What was the customer's RFM status during each historical fiscal year?**

Allowing the FY2018 RFM classification to respond to earlier date filters could combine historical period metrics with a customer classification calculated from later behavior.

For example, filtering the report to FY2016 while displaying the FY2018 RFM segment would not represent the customer's FY2016 segment.

### Power BI Design

The RFM snapshot is therefore treated independently from the report's normal time filtering.

Date filters should not imply that the RFM segmentation is being recalculated for the selected historical period.

The RFM visuals may still respond to appropriate non-date dimensions, such as:

* Region
* Segment
* Category

where those filters are analytically meaningful.

### Limitation

A dynamically changing historical RFM analysis would require separate RFM snapshots for multiple points in time.

For example:

```text
Customer
    │
    ├── FY2016 Snapshot
    ├── FY2017 Snapshot
    └── FY2018 Snapshot
```

---

## 3.10 AOV as a Separate Customer Metric

### Decision

Average Order Value was treated as a separate KPI rather than combining it with total revenue into one visualization.

### Why?

Revenue and AOV answer different business questions:

**Revenue:**

> How much money is being generated?

**AOV:**

> How much value does the average order generate?

Combining them into a single visual could make the distinction less clear.

Keeping AOV separate allows the dashboard to evaluate order value independently from overall revenue volume.

---

# 3.11 Cohort Retention Matrix

### Decision

Cohort retention was presented as a matrix rather than a conventional chart.

### Why?

Retention is inherently two-dimensional:

```text id="7qv9hi"
Cohort
   ×
Months Since First Purchase
```

A matrix allows the user to see:

* Initial cohort size
* Retention over time
* Differences between cohorts
* Changes in retention patterns

Conditional formatting provides visual emphasis without requiring additional charts.

### Design principle

The matrix prioritizes **pattern recognition** over precise point-by-point comparison.

---

# 3.12 Growth & Risk as a Separate Analytical Page

### Decision

Growth and risk analysis were grouped into a dedicated dashboard page rather than being placed primarily on the executive overview.

### Why?

Growth and risk are more diagnostic than descriptive.

The executive page answers:

> **How are we performing?**

The growth and risk page asks:

> **Where is performance changing, and where might attention be required?**

This page therefore combines:

* Growth KPIs
* Growth trends
* Seasonality
* Risk indicators
* Revenue opportunity indicators

---

# 3.13 Growth KPI Design

### Decision

The growth KPI section focuses on metrics that answer distinct business questions rather than displaying multiple versions of the same growth rate.

Selected KPIs include:

* Category YoY Sales Growth
* Category YoY Profit Growth
* CAGR
* Months with Growth

### Why?

Each metric provides a different perspective:

| KPI                        | Question                                                 |
| -------------------------- | -------------------------------------------------------- |
| Category YoY Sales Growth  | Which categories are growing?                            |
| Category YoY Profit Growth | Which categories are becoming more or less profitable?   |
| CAGR                       | What is the long-term annualized growth rate?            |
| Months with Growth         | How consistently is the business growing month to month? |

This avoids filling the KPI section with metrics that provide largely redundant information.

---

# 3.14 Risk KPI Design

### Decision

The risk section focuses on **revenue exposure and opportunity** rather than attempting to display a generic count of "high-risk customers."

### Why?

A customer count does not necessarily communicate the financial importance of the risk.

For example:

```text id="zxy9q7"
10 high-risk customers
```

could represent either a very small or very large amount of revenue.

Revenue-based KPIs provide greater business context.

The report therefore emphasizes metrics such as:

* Revenue At Risk
* Revenue Opportunity

### Revenue At Risk

Represents revenue associated with customers classified as **At Risk - High Value**.

### Revenue Opportunity

Represents revenue associated with **High Value / Irregular Customers** whose behavior may represent an opportunity for increased engagement.

### Important distinction

These metrics are **descriptive indicators based on historical customer behavior**.

They are not predictive churn or revenue forecasts.

---

# 3.15 Revenue At Risk vs Revenue Opportunity

### Decision

Revenue At Risk and Revenue Opportunity are presented together as complementary indicators.

### Why?

They represent two different sides of customer management:

```text id="n2b0qk"
Revenue At Risk
→ Protect existing value

Revenue Opportunity
→ Develop existing value
```

This creates a more actionable view of customer behavior than simply reporting the number of customers in each RFM segment.

---

# 3.16 Data Completeness Indicator

### Decision

The dashboard includes dynamic minimum and maximum available dates.

### Why?

Growth metrics can be misleading when the underlying historical period is incomplete.

For example, comparing a partial fiscal period with a complete period can produce misleading growth rates.

Displaying the available date range allows users to understand the temporal coverage of the current report context.

The indicators respond to the active filter context, allowing users to see the date coverage of their current selection.

---

# 3.17 Bookmark-Based Page Navigation

### Decision

Bookmarks were used to create a persistent page-navigation experience.

### Why?

The dashboard contains multiple analytical pages, and direct navigation through standard Power BI tabs can make the report feel less cohesive.

The navigation bar provides a consistent interface for moving between:

* Executive Overview
* Customer Analysis
* Product & Geographic Performance
* Growth & Trends

Bookmarks were configured to control the navigation state without unnecessarily altering report filters.

### Design principle

Navigation should improve usability without unexpectedly changing the analytical context selected by the user.

---

# 3.18 Tooltip Design

### Decision

Tooltips were used to provide additional context without overcrowding the main dashboard visuals.

### Why?

The primary visuals are intentionally kept relatively clean.

Additional information can therefore be surfaced on hover, such as:

* Sales
* Profit
* Margin
* Growth
* Customer count
* Order count
* Supporting metrics

This allows the dashboard to maintain a clean visual hierarchy while still providing deeper information when required.

---

# 3.19 Visual Hierarchy

### Decision

Dashboard elements are organized according to analytical importance.

The general hierarchy is:

```text id="8f14kz"
KPIs
  ↓
Primary Visuals
  ↓
Supporting Visuals
  ↓
Detailed Context / Tooltips
```

### Why?

Users should be able to understand the most important business information quickly before exploring detailed analysis.

This prevents the dashboard from becoming a collection of equally weighted charts.

---

# 3.20 Filter Context and Navigation

### Decision

Page navigation was designed to preserve the user's analytical filter context rather than unexpectedly clearing filters when moving between pages.

### Why?

If a user filters the report to a particular fiscal year, region, or category, they generally expect that analytical context to remain relevant when navigating through the report.

This makes navigation behave as movement through a single analytical report rather than switching between independent dashboard states.

---

# Power BI Design Principles

## Context Before Detail

The report progresses from high-level performance toward increasingly detailed analysis.

```text id="j8tw7y"
Executive Performance
        ↓
Customer Behavior
        ↓
Product / Geographic Performance
        ↓
Growth & Risk
```

---

## One Visual, One Primary Question

Each major visual should have a clear analytical purpose.

A visual should not exist simply because the underlying dataset contains another dimension that can be plotted.

---

## KPIs Should Support Decisions

KPIs were selected based on the business questions they answer rather than the number of metrics available.

---

## Avoid Redundant Metrics

Where multiple metrics describe the same underlying concept, the report prioritizes the metric that provides the clearest business interpretation.

---

## Keep the Main Canvas Clean

Supporting detail is moved into:

* Tooltips
* Secondary visuals
* Interactive filters

rather than placing every available metric directly onto the canvas.

---

# Outcome

The Power BI layer acts as the interactive analytical interface over the SQL model.

The resulting separation is:

```text id="g4plw2"
SQL Server
→ Data model + reusable analytical structures

DAX
→ Dynamic, filter-aware metrics

Power BI
→ Visualization + interaction + reporting
```

This allows the dashboard to communicate both **what happened** and **where further business attention may be required**, without turning the report into an unnecessarily dense collection of metrics.
