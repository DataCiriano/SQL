/*
CASE 04: Data Bank - Case Study A: Customer Nodes Exploration

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-4/
*/

--CUSTOMER NODES EXPLORATION

--QUESTION 1 : How many unique nodes are there on the Data Bank system?

    SELECT COUNT(DISTINCT node_id) AS total_unique_nodes
    FROM data_bank.customer_nodes;

--QUESTION 2: What is the number of nodes per region?

    SELECT 
        regions.region_name, 
        COUNT(DISTINCT node_id) AS nodes_by_region
    FROM data_bank.customer_nodes
    JOIN regions ON regions.region_id = customer_nodes.region_id
    GROUP BY customer_nodes.region_id, regions.region_name;

--QUESTION 3: How many customers are allocated to each region?

    SELECT 
        regions.region_name, 
        COUNT(DISTINCT customer_id) AS customer_by_region
    FROM data_bank.customer_nodes
    JOIN regions ON regions.region_id = customer_nodes.region_id
    GROUP BY  regions.region_name;

--QUESTION 4: How many days on average are customers reallocated to a different node?

    WITH days AS (
        SELECT 
            customer_id,
            region_id,
            node_id,
            MIN(start_date) AS first_date 
        FROM customer_nodes
        GROUP BY customer_id, region_id, node_id
    ),
    moves AS (
        SELECT
            customer_id,
            region_id,
            node_id,
            first_date,
            DATEDIFF((LEAD(first_date) OVER(PARTITION BY customer_id ORDER BY first_date))  , (first_date)) AS days_to_move
        FROM days
    )

    SELECT 
        ROUND(AVG(days_to_move),0) AS avg_days
    FROM moves;

/*
--Explanation: 
The 'days' subquery is used to calculate the first day for each customer by region and node, then the 'movements' subquery uses the LEAD() 
window function to get the next date for each customer and then subtract 'first_date' getting the total days to move for each customer (DATEDIFF
is necessary because if the two dates are just subtracted, the result will be a date, not the number of days between the dates). 
The main query calculates the average days to move.
*/

--Another way to answer the question

    WITH node_days AS (
        SELECT 
            customer_id, 
            node_id,
            end_date - start_date AS days_in_node
        FROM customer_nodes
        WHERE end_date != '9999-12-31'
        GROUP BY customer_id, node_id, start_date, end_date
    ) , 
    total_node_days AS (
        SELECT 
            customer_id,
            node_id,
            SUM(days_in_node) AS total_days_in_node
        FROM node_days
        GROUP BY customer_id, node_id
    )

    SELECT ROUND(AVG(total_days_in_node)) AS avg_node_reallocation_days
    FROM total_node_days;

--QUESTION 5: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

    WITH days AS (
    SELECT 
        customer_id,
        region_id,
        node_id,
        MIN(start_date) AS first_date 
    FROM customer_nodes
    GROUP BY customer_id, region_id, node_id
    ),
    moves AS (
        SELECT
            customer_id,
            region_id,
            node_id,
            first_date,
            DATEDIFF(LEAD(first_date) OVER(PARTITION BY customer_id ORDER BY first_date), first_date) AS days_to_move
        FROM days
    )

SELECT
    region_id,
    region_name,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY region_id) AS median_50,
    PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY region_id) AS median_80,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY region_id) AS median_95,
FROM moves;

/*
--Explanation: The two subqueries are the same as in the previous question. The main query use a window function calles PERCENTILE_CONT to get 
the different percentiles.
    PERCENTILE_CONT: calculates continous percentiles doing interpolation if necessary.
   
