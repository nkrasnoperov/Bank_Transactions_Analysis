-- PROJECT: Bank Transactions Analysis

CREATE DATABASE bank_transactions;

USE bank_transactions_data;

-- 01. DATASET OVERVIEW
-- How many transactions and accounts are in the dataset, and what period does the data cover?
SELECT
    COUNT(*) AS TotalTransactions,
    COUNT(DISTINCT AccountID) AS UniqueAccounts,
    MIN(TransactionDate) AS FirstTransactionDate,
    MAX(TransactionDate) AS LastTransactionDate
FROM bank_transactions_data;

-- 02. TRANSACTION SUMMARY BY LOCATION AND OCCUPATION
-- Which location/occupation combinations have the highest average transaction amounts?
SELECT
    Location,
    CustomerOccupation,
    COUNT(*) AS TotalTransactions,
    ROUND(SUM(TransactionAmount), 2) AS TotalAmount,
    ROUND(AVG(TransactionAmount), 2) AS AvgTransaction,
    ROUND(MIN(TransactionAmount), 2) AS MinTransaction,
    ROUND(MAX(TransactionAmount), 2) AS MaxTransaction,
    ROUND(STDDEV_SAMP(TransactionAmount), 2) AS StdDevTransaction
FROM bank_transactions_data
GROUP BY Location, CustomerOccupation
ORDER BY AvgTransaction DESC;

-- 03. TRANSACTION TYPES
-- Which transaction type represents the highest recorded transaction value?
SELECT
    TransactionType,
    COUNT(*) AS TotalTransactions,
    ROUND(SUM(TransactionAmount), 2) AS TotalValue,
    ROUND(AVG(TransactionAmount), 2) AS AvgValue
FROM bank_transactions_data
GROUP BY TransactionType
ORDER BY TotalValue DESC;

-- 04. MONTHLY TRANSACTION ACTIVITY
-- How do transaction count and value change by month?
SELECT
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    COUNT(*) AS Transactions,
    ROUND(SUM(TransactionAmount), 2) AS TotalValue,
    ROUND(AVG(TransactionAmount), 2) AS AvgTransaction
FROM bank_transactions_data
GROUP BY DATE_FORMAT(TransactionDate, '%Y-%m')
ORDER BY Month;

-- 05. CUSTOMER AGE GROUPS
-- Which age groups have the highest average transaction?
SELECT
    CASE
        WHEN CustomerAge IS NULL THEN 'Unknown'
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

-- 06. BANKING CHANNEL USAGE
-- Which channels are used most, and what proportion of all transactions does each channel represent?
SELECT
    Channel,
    COUNT(*) AS Transactions,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_transactions_data),
        2
    ) AS PercentageOfTotal,
    ROUND(AVG(TransactionAmount), 2) AS AvgAmount
FROM bank_transactions_data
GROUP BY Channel
ORDER BY Transactions DESC;

-- 07. HIGH-AVERAGE-TRANSACTION ACCOUNTS
-- Which accounts have the highest average transaction amount among accounts with at least three transactions?
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
    ROUND(MaxAmount, 2) AS MaxAmount,
    RANK() OVER (ORDER BY AvgAmount DESC) AS AmountRank
FROM account_stats
ORDER BY AmountRank, AccountID
LIMIT 10;

-- 08. LOGIN ATTEMPTS AND TRANSACTION BEHAVIOUR
-- How do transaction size and duration vary across login-attempt groups?
SELECT
    CASE
        WHEN LoginAttempts = 0 THEN '0 attempts'
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