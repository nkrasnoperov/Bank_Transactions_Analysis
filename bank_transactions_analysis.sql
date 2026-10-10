# PROJECT: Bank Transactions Analysis

CREATE DATABASE bank_transactions;

USE bank_transactions_data;

SELECT *
FROM bank_transactions_data
LIMIT 10;

# Summary statistics
SELECT
    Location,
    CustomerOccupation,
    COUNT(*) AS TotalTransactions,
    ROUND(SUM(TransactionAmount), 2) AS TotalAmount,
    ROUND(AVG(TransactionAmount), 2) AS AvgTransaction,
    MIN(TransactionAmount) AS MinTransaction,
    MAX(TransactionAmount) AS MaxTransaction,
    ROUND(STDDEV_SAMP(TransactionAmount), 2) AS StdDevTransaction
FROM bank_transactions_data
GROUP BY Location, CustomerOccupation
ORDER BY AvgTransaction DESC;

# Checking which transaction types account for the highest spend
SELECT
    TransactionType,
    COUNT(*) AS TotalTransactions,
    ROUND(SUM(TransactionAmount), 2) AS TotalValue,
    ROUND(AVG(TransactionAmount), 2) AS AvgValue
FROM bank_transactions_data
GROUP BY TransactionType
ORDER BY TotalValue DESC;

#Change in transaction activity over time
SELECT
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    COUNT(*) AS Transactions,
    ROUND(SUM(TransactionAmount), 2) AS TotalValue,
    ROUND(AVG(TransactionAmount), 2) AS AvgTransaction
FROM bank_transactions_data
GROUP BY DATE_FORMAT(TransactionDate, '%Y-%m')
ORDER BY Month;

# Transaction patterns across different age groups
SELECT
    CASE
        WHEN CustomerAge < 25 THEN 'Under 25'
        WHEN CustomerAge < 35 THEN '25-34'
        WHEN CustomerAge < 45 THEN '35-44'
        WHEN CustomerAge < 55 THEN '45-54'
        ELSE '55+'
    END AS AgeGroup,
    COUNT(*) AS Transactions,
    ROUND(AVG(TransactionAmount), 2) AS AvgAmount
FROM bank_transactions_data
GROUP BY AgeGroup
ORDER BY AvgAmount DESC;

# Reviewing banking channels
SELECT
    Channel,
    COUNT(*) AS Transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bank_transactions_data),
        2
    ) AS PercentageOfTotal,
    ROUND(AVG(TransactionAmount), 2) AS AvgAmount
FROM bank_transactions_data
GROUP BY Channel
ORDER BY Transactions DESC;

# Identifying customers who have made several transactions and have a high average transaction amount
WITH account_stats AS (
    SELECT
        AccountID,
        COUNT(*) AS TotalTransactions,
        AVG(TransactionAmount) AS AvgAmount,
        MAX(TransactionAmount) AS MaxAmount
    FROM bank_transactions_data
    GROUP BY AccountID
    HAVING COUNT(*) >= 3
)
SELECT
    AccountID,
    TotalTransactions,
    ROUND(AvgAmount, 2) AS AvgAmount,
    MaxAmount,
    RANK() OVER (
        ORDER BY AvgAmount DESC
    ) AS AmountRank
FROM account_stats
ORDER BY AmountRank
LIMIT 10;

# Checking if repeated login attempts correlate with transaction size
SELECT
    CASE
        WHEN LoginAttempts = 1 THEN '1 attempt'
        WHEN LoginAttempts BETWEEN 2 AND 3 THEN '2-3 attempts'
        ELSE '4+ attempts'
    END AS LoginGroup,
    COUNT(*) AS Transactions,
    ROUND(AVG(TransactionAmount), 2) AS AvgAmount,
    ROUND(AVG(TransactionDuration), 2) AS AvgDuration
FROM bank_transactions_data
WHERE LoginAttempts IS NOT NULL
GROUP BY LoginGroup
ORDER BY AvgAmount DESC;