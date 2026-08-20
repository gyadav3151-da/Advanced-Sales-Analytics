# 5. Trade-offs & Limitations

This section documents the main trade-offs and limitations identified during the development of Advanced Sales Analytics V2.

The purpose is not to present the project as a perfect production system, but to explain the compromises made within the scope, dataset, and objectives of the project.

---

# 5.1 Dataset Limitations

### Decision

The project uses the provided Superstore dataset as its source of truth rather than attempting to reconstruct or supplement the historical data.

### Limitation

The dataset represents a fixed historical period and does not provide an ongoing or complete production data stream.

As a result:

* The dataset cannot demonstrate real-time reporting.
* Future performance cannot be evaluated.
* Some growth calculations are affected by the available historical boundaries.
* The first available year does not have a prior year within the dataset.

These limitations are considered when interpreting growth metrics.

---

# 5.2 Partial Period Comparisons

Some comparisons may involve periods with different levels of data completeness.

For example, the beginning or ending fiscal year may not contain the same number of months as an adjacent year.

This can affect:

* YoY growth
* CAGR
* MoM comparisons
* Seasonal interpretation

The dashboard therefore includes dynamic minimum and maximum date indicators to provide visibility into the available data range.

---

# 5.3 First-Year Growth Distortion

The first year in the dataset represents the beginning of the available history.

Consequently, the following year's YoY growth can appear unusually large when compared with the relatively small initial period.

This does not necessarily indicate an abnormal business event.

### Implication

Large early-period growth rates should therefore be interpreted in the context of:

* Beginning-period revenue
* Available historical coverage
* Period completeness

The project retains these metrics because they accurately describe the available data, while recognizing that they may not represent a normalized long-term growth rate.

---

# 5.4 RFM Segmentation Is Relative

RFM scoring uses relative customer rankings rather than fixed business thresholds.

This means that customer scores and resulting segments depend on the distribution of customers within the dataset.

### Implication

A customer classified as high value in this dataset is not necessarily equivalent to a customer who would meet a predefined monetary threshold in another business.

The RFM segments should therefore be interpreted as **relative behavioral groups within this dataset**.

---

# 5.5 RFM Is a FY2018 Snapshot

The RFM model represents a point-in-time snapshot calculated using customer behavior up to the end of FY2018.

It therefore describes customer status at the end of the available analysis period rather than providing a historical RFM classification for every fiscal year.

### Implication

The RFM segmentation should not be interpreted as a time-series measure.

For example, a FY2018 customer classified as:

```text
Champion
```

does not necessarily mean that the same customer would have been classified as a Champion in FY2016.

Similarly, applying an earlier fiscal-year filter to an FY2018 RFM classification could combine historical transaction metrics with a later customer classification.

### Design Response

The Power BI report therefore treats the RFM snapshot independently from historical date filtering.

A dynamically historical RFM model would require multiple point-in-time snapshots, which was outside the scope of V2.

### Production Extension

A production implementation could maintain periodic RFM snapshots:

```text
Customer
    ↓
Snapshot Date
    ↓
RFM Metrics
    ↓
RFM Score
    ↓
RFM Segment
```

This would allow customer segments to be analyzed as they changed over time.

---

# 5.6 Revenue At Risk Is Not Predictive Churn

It represents historical revenue associated with this segment.

Revenue At Risk is based on customers classified as:

```text
At Risk - High Value
```

It does not calculate:

* Probability of churn
* Expected future revenue loss
* Customer lifetime value at risk

### Implication

The KPI should be interpreted as a **risk indicator**, not a predictive churn model.

A production implementation could extend this analysis with behavioral or predictive churn modeling.

---

# 5.7 Revenue Opportunity Is Not Forecast Revenue

Revenue Opportunity is based on the historical revenue associated with:

```text
High Value / Irregular Customers
```

It indicates a potentially valuable customer group that may warrant further engagement.

It does not represent:

* Forecast incremental revenue
* Expected conversion value
* Guaranteed recoverable revenue

### Implication

The metric identifies a **potential opportunity area**, rather than estimating the financial return of a specific intervention.

---

# 5.8 SQL vs Power BI Logic

Some logic exists in SQL while other logic exists in DAX.

SQL is primarily responsible for:

* Data storage
* Core modeling
* Reusable analytical structures
* RFM preparation
* Cohort analysis

Power BI / DAX is primarily responsible for:

* Dynamic measures
* Report-specific calculations
* Fiscal reporting logic
* Time-intelligence calculations
* Interactive reporting

### Trade-off

This separation improves flexibility within Power BI, but means that not every analytical result can be reproduced solely from the SQL layer without recreating the corresponding DAX logic.

---

# 5.9 Fiscal Logic in the Reporting Layer

Fiscal Year and Fiscal Year Month were implemented in DAX rather than in the SQL calendar dimension.

### Trade-off

This keeps the SQL calendar general-purpose and allows report-specific fiscal logic to remain within Power BI.

However, another reporting platform consuming the SQL model would not automatically inherit these fiscal attributes.

For a production environment supporting multiple reporting systems, centralizing the fiscal calendar in the warehouse may be preferable.

---

# 5.10 Dataset Scale

The Superstore dataset contains approximately 10,000 transaction records.

This is sufficient for demonstrating:

* SQL analytical techniques
* Dimensional modeling
* DAX
* Customer segmentation
* Cohort analysis
* Power BI reporting

However, it is not representative of the scale or complexity of a large production analytics environment.

The project therefore focuses on demonstrating **analytical design and reasoning** rather than large-scale performance engineering.

---

# 5.11 No Predictive Modeling

The project intentionally remains within descriptive and diagnostic analytics.

It does not currently include:

* Churn prediction
* Sales forecasting
* Customer lifetime value prediction
* Predictive propensity models

### Reason

The primary objective of V2 was to strengthen the analytical workflow and business interpretation of historical data.

Predictive modeling could be added as a future extension once the descriptive analytical foundation is established.

---

# 5.12 No Real-Time Data Pipeline

The project operates on a static dataset and does not implement:

* Scheduled ingestion
* Incremental loading
* Streaming data
* Automated refresh infrastructure

### Implication

The workflow demonstrates an analytical pipeline rather than a production-grade continuously refreshed data platform.

---

# 5.13 Dashboard Complexity vs Usability

Additional analytical features create a trade-off between analytical depth and visual simplicity.

The project therefore prioritizes:

* Clear visual hierarchy
* Limited primary KPIs
* Supporting tooltips
* Dedicated analytical pages
* Bookmark-based navigation

rather than attempting to display every available metric on a single page.

This keeps the dashboard focused while allowing deeper analysis through interaction.

---

# 5.14 Trade-off Summary

| Area                | Decision                                | Trade-off                                 |
| ------------------- | --------------------------------------- | ----------------------------------------- |
| Dataset             | Use provided Superstore data            | Limited historical and production realism |
| RFM                 | Relative scoring                        | Segments are dataset-dependent            |
| Revenue At Risk     | Historical segment revenue              | Not predictive churn                      |
| Revenue Opportunity | Historical high-value irregular revenue | Not forecast incremental revenue          |
| Fiscal Logic        | Implemented in DAX                      | Not available directly in SQL             |
| Analytics           | Descriptive / diagnostic                | No predictive modeling                    |
| Data Pipeline       | Static dataset                          | No real-time or automated ingestion       |
| Dashboard           | Focused multi-page design               | Less information visible simultaneously   |

---

# 5.15 Future Extensions

The current architecture provides a foundation for future improvements.

Potential extensions include:

* Automated data ingestion
* Incremental data loading
* Production-scale warehouse modeling
* Predictive churn modeling
* Sales forecasting
* Customer lifetime value modeling
* More sophisticated revenue opportunity estimation
* Automated Power BI refresh
* Additional data sources

These are considered future extensions rather than requirements for the current project.

---

# Conclusion

The project deliberately balances analytical depth with maintainability and usability.

The identified limitations do not invalidate the analysis; instead, they provide important context for interpreting its results.

Documenting these trade-offs demonstrates that the project decisions were made with awareness of both their benefits and their limitations.
