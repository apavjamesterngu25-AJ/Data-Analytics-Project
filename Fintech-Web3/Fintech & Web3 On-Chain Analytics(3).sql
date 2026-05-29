
-- Network Congestion & Fee Trends:

-- Find daily transaction counts,
-- FROM  https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=crypto_ethereum&page=dataset

SELECT
  DATE(block_timestamp) AS transaction_date, COUNT(*) AS daily_transaction_count
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY transaction_date
ORDER BY transaction_date ASC;

-- Total value transferred (ETH),
-- FROM  https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=crypto_ethereum&page=dataset

SELECT
  DATE(block_timestamp) AS transaction_date,
  COUNT(*) AS daily_transaction_count,
  SUM(value / POW(10, 18)) AS total_eth_transferred
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY transaction_date
ORDER BY transaction_date ASC;

-- Average gas price over 30 days.,
-- FROM  https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=crypto_ethereum&page=dataset

SELECT
  DATE(block_timestamp) AS transaction_date, AVG(gas_price) AS average_gas_price
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY transaction_date
ORDER BY transaction_date;


-- Whale Wallet Tier Segmentation
-- Categorize active addresses by volume: Whale (>= 1k ETH), Shark (100-999), Fish (< 100)

SELECT
  from_address,
  SUM(value / POW(10, 18)) AS total_eth_transferred,
  CASE
    WHEN SUM(value / POW(10, 18)) >= 1000 THEN 'Whale'
    WHEN SUM(value / POW(10, 18)) >= 100 THEN 'Shark'
    ELSE 'Fish'
    END
    AS category
FROM `bigquery-public-data.crypto_ethereum.traces`
WHERE
  block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND status = 1
  AND from_address IS NOT NULL
  AND value > 0
GROUP BY from_address
ORDER BY total_eth_transferred DESC;

-- Daily Top-Value Transfers
-- Isolate the top 5 largest value transactions for each day of the last week

SELECT transaction_date, tx_hash, value_eth
FROM
  (
    SELECT
      DATE(block_timestamp) AS transaction_date,
      `hash` AS tx_hash,
      value / POW(10, 18) AS value_eth,
      ROW_NUMBER()
        OVER (PARTITION BY DATE(block_timestamp) ORDER BY value DESC) AS rank
    FROM `bigquery-public-data.crypto_ethereum.transactions`
    WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  )
WHERE rank <= 5
ORDER BY transaction_date DESC, value_eth DESC;

-- Rolling Cost Forecast
-- Calculate a 7-day moving average of gas prices (in Gwei) to identify cost-efficient windows

SELECT
  daily_stats.transaction_date AS `date`,
  daily_stats.daily_avg_gas_price_gwei,
  AVG(daily_stats.daily_avg_gas_price_gwei)
    OVER (
      ORDER BY daily_stats.transaction_date ASC
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )
    AS seven_day_moving_avg_gwei
FROM
  (
    SELECT
      DATE(block_timestamp) AS transaction_date,
      AVG(gas_price / 1000000000) AS daily_avg_gas_price_gwei
    FROM `bigquery-public-data.crypto_ethereum.transactions`
    WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    GROUP BY transaction_date
  ) AS daily_stats
ORDER BY `date` DESC;


