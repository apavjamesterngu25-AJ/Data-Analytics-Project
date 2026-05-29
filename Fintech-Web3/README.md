Fintech & Web3 On-Chain Analytics

📌 Project Overview This project focuses on blockchain data analytics, specifically evaluating network activity and economic throughput on the Ethereum mainnet. By analyzing transaction frequencies and value distribution, this project provides insights into Web3 network congestion patterns and user transaction behavior over a trailing 30-day window.

🛠️ Data Source & Tools * Data Source: bigquery-public-data.crypto_ethereum.transactions (Google BigQuery Public Datasets) * Technology Stack: Google BigQuery, Standard SQL * Platform: GitHub (Version Control)

🔍 Key Analyses Performed
1. Network Congestion & Daily Transaction Volume * Objective: Track daily transaction velocity to monitor Ethereum network activity levels. * Logic: Aggregates total daily transaction counts and filters data strictly to the last 30 days using TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY) to maintain a rolling analysis window. * Ordering: Sorted chronologically (ORDER BY transaction_date ASC) to observe day-over-day changes.
2. 
3. Transaction Value Throughput (ETH) * Objective: Measure total value transferred on-chain per day. * Logic: Converts raw cryptographic values from internal processing metrics (value) into human-readable Ether (ETH) using the standard base conversion metric SUM(value / POW(10, 18)). * Value: Highlights economic transaction trends to distinguish between high-volume retail trading and institutional movement days.
4. 
💡 Expected Insights & Value * Gas & Fee Forecasting: Spikes in transaction counts serve as leading indicators for network congestion
