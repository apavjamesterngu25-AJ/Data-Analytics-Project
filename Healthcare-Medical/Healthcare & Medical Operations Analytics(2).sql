-- Hospital Cost Markup Analysis
-- Calculate markup ratio (covered charges / total payments) for top hospitals
-- Using the 2014 dataset

SELECT
  provider_name,
  SUM(average_covered_charges) AS total_covered_charges,
  SUM(average_total_payments) AS total_payments,
  SAFE_DIVIDE(SUM(average_covered_charges), SUM(average_total_payments))
    AS markup_ratio
FROM `bigquery-public-data.medicare.inpatient_charges_2014`
GROUP BY provider_name
ORDER BY markup_ratio DESC
LIMIT 10;


-- Geographic Price Variance
-- Find avg payments for top 5 procedures across US States. Rank states by cost.

WITH
  TopProcedures AS (
    SELECT drg_definition
    FROM `bigquery-public-data.medicare.inpatient_charges_2014`
    GROUP BY drg_definition
    ORDER BY SUM(total_discharges) DESC
    LIMIT 5
  )
SELECT
  t1.drg_definition,
  t1.provider_state,
  AVG(t1.average_total_payments) AS avg_payment_per_state,
  RANK()
    OVER (
      PARTITION BY t1.drg_definition
      ORDER BY AVG(t1.average_total_payments) DESC
    )
    AS state_cost_rank
FROM `bigquery-public-data.medicare.inpatient_charges_2014` AS t1
JOIN TopProcedures AS tp
  ON t1.drg_definition = tp.drg_definition
GROUP BY t1.drg_definition, t1.provider_state
ORDER BY t1.drg_definition, state_cost_rank;


-- Statistical Outlier Detection
-- Identify providers charging > 2 standard deviations above the national average per procedure

WITH
  NationalProcedureStats AS (
    SELECT
      drg_definition,
      AVG(average_covered_charges) AS national_avg_charge,
      STDDEV(average_covered_charges) AS national_stddev_charge
    FROM `bigquery-public-data.medicare.inpatient_charges_2014`
    GROUP BY drg_definition
  )
SELECT
  t.provider_name,
  t.drg_definition,
  t.average_covered_charges,
  nps.national_avg_charge,
  (t.average_covered_charges - nps.national_avg_charge)
    / nps.national_stddev_charge
    AS std_devs_above_avg
FROM `bigquery-public-data.medicare.inpatient_charges_2014` AS t
JOIN NationalProcedureStats AS nps
  ON t.drg_definition = nps.drg_definition
WHERE
  t.average_covered_charges
    > nps.national_avg_charge + (2 * nps.national_stddev_charge)
  AND nps.national_stddev_charge > 0
ORDER BY std_devs_above_avg DESC;

-- Cross-Domain Analysis
-- Join inpatient data with Part D prescriber data to evaluate regional cost correlations

WITH
  InpatientCosts AS (
    SELECT
      provider_state AS state, AVG(average_total_payments) AS avg_inpatient_cost
    FROM `bigquery-public-data.medicare.inpatient_charges_2014`
    GROUP BY state
  ),
  PartDDrugCosts AS (
    SELECT
      nppes_provider_state AS state, AVG(total_drug_cost) AS avg_partd_drug_cost
    FROM `bigquery-public-data.medicare.part_d_prescriber_2014`
    GROUP BY state
  )
SELECT
  ic.state,
  ic.avg_inpatient_cost,
  pdc.avg_partd_drug_cost,
  CORR(ic.avg_inpatient_cost, pdc.avg_partd_drug_cost)
    OVER () AS cost_correlation
FROM InpatientCosts AS ic
JOIN PartDDrugCosts AS pdc
  ON ic.state = pdc.state
ORDER BY ic.state;





