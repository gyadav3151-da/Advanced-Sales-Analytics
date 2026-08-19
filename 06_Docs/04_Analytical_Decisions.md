# 4. Analytical Decisions

This section documents the analytical decisions made in Advanced Sales Analytics V2.

The purpose of the V2 analysis was to move beyond basic sales reporting and investigate **customer behavior, retention, profitability, growth, and revenue risk**.

The analyses were selected based on the business questions they could answer rather than simply the availability of dimensions in the dataset.

---

# 4.1 From Sales Reporting to Business Analysis

### Decision

The project was expanded from basic sales and profitability reporting into a broader analytical framework.

The original project primarily focused on:

* Sales
* Profit
* Products
* Regions
* Categories
* Customer segments
* Basic trends

V2 expands this into:

```text
Business Performance
        ↓
Customer Behavior
        ↓
Customer Retention
        ↓
Growth
        ↓
Risk & Opportunity
```

### Why?

A dashboard showing what happened is useful, but a stronger analytical project should also investigate:

* Why performance may be changing
* Which customers contribute value
* Whether customers remain engaged
* Where growth is occurring
* Where revenue may be exposed
* Where existing customers may represent an opportunity

This became the primary analytical direction of V2.

---

# 4.2 Why Use Both RFM and Cohort Analysis?

### Decision

RFM and cohort analysis were intentionally kept as complementary analyses.

### Why?

They answer different questions.

| Analysis | Primary Question                           |
| -------- | ------------------------------------------ |
| RFM      | What type of customer is this?             |
| Cohort   | How well are customers retained over time? |

For example, RFM may identify a group of high-value customers, while cohort analysis may reveal that newer cohorts are retaining less effectively than older cohorts.

Using both provides a more complete view of customer health.

---


# 4.3 Growth Analysis

### Decision

V2 uses multiple growth perspectives rather than relying on a single growth metric.

The analysis includes:

* YoY Sales Growth
* MoM Sales Growth
* Months with Growth
* CAGR
* Category YoY Sales Growth
* Category YoY Profit Growth

### Why?

Different growth metrics answer different questions.

| Metric                     | Question                                                      |
| -------------------------- | ------------------------------------------------------------- |
| YoY Growth                 | How does performance compare with the previous year?          |
| MoM Growth                 | How is performance changing month to month?                   |
| Months with Growth         | How consistently is the business growing?                     |
| CAGR                       | What is the annualized long-term growth rate?                 |
| Category YoY Sales Growth  | Which categories are driving sales growth?                    |
| Category YoY Profit Growth | Which categories are improving or declining in profitability? |

Using multiple perspectives reduces the risk of interpreting growth from a single metric.

---

# 4.4 Profitability Growth

### Decision

Category-level profit growth was analyzed alongside category sales growth.

### Why?

Sales growth alone does not necessarily indicate improved business performance.

A category may generate more sales while simultaneously generating less profit.

Therefore:

```text id="9fd5w2"
Sales Growth
+
Profit Growth
```

provides a more complete view of category performance.

### Business Question

> **Are growing categories also becoming more profitable?**

This helps distinguish revenue growth from economically meaningful growth.

---

# 4.5 Revenue Seasonality

### Decision

Seasonality was analyzed using monthly revenue patterns.

### Why?

Aggregated annual or quarterly results can hide recurring monthly patterns.

Identifying seasonality can help answer:

* Which months typically perform strongly?
* Which months tend to underperform?
* Are there recurring periods of increased demand?

### Business Question

> **Are there recurring periods of stronger or weaker revenue performance?**

### Business Use

Seasonality can inform decisions around:

* Marketing
* Inventory
* Staffing
* Promotions

---

# 4.6 Growth, Risk & Opportunity

### Decision

Growth answers where the business is expanding, while risk and opportunity focus on where existing customer value may require attention or development.

### Why?

Customer analytics should not focus exclusively on problems.

The project distinguishes between:

```text id="wq0x5b"
Risk
→ Protect existing value

Opportunity
→ Develop existing value
```

This creates a more balanced business perspective.

For example:

* At Risk - High Value customers may require retention efforts.
* High Value / Irregular customers may require engagement efforts.
* Champions may require loyalty or advocacy strategies.

The purpose is to connect customer segmentation to potential business actions.

---

# 4.7 Descriptive Rather Than Predictive Analysis

### Decision

The project intentionally focuses primarily on descriptive and diagnostic analytics rather than predictive modeling.

### Why?

The objective of V2 is to understand historical business performance and identify patterns that can support business decisions.

The analysis therefore focuses on:

* What happened?
* Where did it happen?
* Which customers contributed?
* How did behavior change?
* Which areas may require attention?

Rather than attempting to predict:

* Future sales
* Customer churn probability
* Future customer lifetime value
* Future revenue

### Result

Metrics such as RFM segments, Revenue At Risk, and Revenue Opportunity are treated as **analytical indicators**, not predictive models.

---

# 4.8 Analytical Framework

The final analytical framework can be summarized as:

```text id="g5q0ae"
Business Performance
    │
    ├── Sales & Profit
    ├── Growth
    └── Seasonality
          │
          ▼
Customer Behavior
    │
    ├── RFM
    ├── AOV
    └── Segmentation
          │
          ▼
Customer Retention
    │
    └── Cohort Analysis
          │
          ▼
Business Risk & Opportunity
    │
    ├── Revenue At Risk
    └── Revenue Opportunity
          │
          ▼
Business Interpretation
```

This structure allows the project to progress from measuring overall performance to understanding **who contributes to that performance, how customer behavior changes over time, and where the business may need to protect or develop existing revenue**.

---

# Analytical Design Principles

## Business Question First

Each analytical technique was selected based on the business question it could answer.

The objective was not to add advanced techniques simply for technical complexity.

---

## Complementary Analysis

Different analytical methods are used to examine the business from different perspectives.

For example:

```text id="t6d0qp"
RFM
→ Customer behavior

Cohort
→ Retention over time

Growth
→ Business trajectory

Profitability
→ Economic quality of growth

Risk / Opportunity
→ Potential action areas
```

---

## Context Before Interpretation

Metrics should always be interpreted within their relevant context.

Examples include:

* Data completeness
* Filter context
* Historical coverage
* Partial periods
* Relative RFM scoring

---

## Descriptive Metrics Are Not Predictions

Indicators such as Revenue At Risk and Revenue Opportunity describe historical customer behavior.

They should not be interpreted as predictions without a separate predictive modeling framework.

---

# Outcome

The analytical framework connects business performance with customer behavior, retention, growth, profitability, seasonality, risk, and opportunity. This allows the dashboard to move beyond reporting historical results toward identifying areas that may require further investigation or action.
