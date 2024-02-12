/*
CASE 04: Data Bank - Case Study B: Customer Transactions

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-4/
*/

--QUESTION 1: What is the unique count and total amount for each transaction type?

    SELECT 
        txn_type,
        COUNT(customer_id) AS total,
        SUM(txn_amount) AS total_amount
    FROM customer_transactions
    GROUP BY txn_type;

--QUESTION 2: What is the average total historical deposit counts and amounts for all customers?

    WITH deposits_by_customer AS(
        SELECT 
            customer_id,
            COUNT(customer_id) AS total_deposits,
            SUM(txn_amount) AS total_amount_deposit
            

        FROM data_bank.customer_transactions
        WHERE txn_type = 'deposit'
        GROUP BY customer_id
    )

SELECT 
	ROUND(AVG(total_deposits)) AS avg_deposits,
    ROUND(AVG(total_amount_deposit),2) AS avg_amount_deposit
FROM deposits_by_customer;

--QUESTION 3: For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

    WITH transaction_count AS (
    SELECT 
        customer_id,
        MONTH(txn_date) AS month_number,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS total_deposits,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS total_purchases,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS total_withdrawals
    FROM customer_transactions
    GROUP BY customer_id, month_number
)

SELECT 
  month_number,
  COUNT(customer_id) AS total_customers
FROM transaction_count
WHERE total_deposits > 1 AND (total_purchases >= 1 OR total_withdrawals >= 1)
GROUP BY month_number
ORDER BY month_number;

/*Explanation: The subquery counts every deposit, purchase and withdrawal made by evry customer each month. The main query sets the condition.
and count the total number of clients who comply.

