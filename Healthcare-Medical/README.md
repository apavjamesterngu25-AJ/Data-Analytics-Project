Healthcare & Medical Operations Analytics
📌 Project Overview

This project performs an in-depth data analytics review of US hospital billing practices using public healthcare data. The analysis focuses on understanding hospital cost markups and geographic price variations across medical procedures. The objective is to identify systemic pricing inefficiencies, extreme markup ratios, and regional cost discrepancies to improve financial transparency in medical operations.
🛠️ Data Source & Tools

    Data Source: bigquery-public-data.medicare.inpatient_charges_2014 (Google BigQuery Public Datasets)
    Technology Stack: Google BigQuery, Standard SQL
    Platform: GitHub (Version Control)

🔍 Key Analyses Performed
1. Hospital Cost Markup Analysis

    Objective: Identify the top 10 hospitals with the highest discrepancy between what they charge versus what they are actually paid.
    Metrics Computed: Total Covered Charges, Total Actual Payments, and a calculated Markup Ratio using SAFE_DIVIDE to avoid mathematical errors.
    Logic: Aggregated and ranked providers in descending order based on their markup multipliers to highlight extreme billing outliers.

2. Geographic Price Variance Analysis

    Objective: Determine how geographic location impacts the cost of medical care for top procedures.
    Logic: Utilized a Common Table Expression (CTE) (WITH TopProcedures AS ...) to isolate the top 5 most common medical procedures (DRG definitions) and rank US states by their average total payment amounts.

💡 Expected Insights & Value

    Operational Inefficiencies: Uncovers huge disparities in what different hospital networks charge for identical inpatient services.
    Strategic Decision Making: Provides baseline metrics that healthcare analysts and policy-makers can use to study medical billing inflation across different regions.

