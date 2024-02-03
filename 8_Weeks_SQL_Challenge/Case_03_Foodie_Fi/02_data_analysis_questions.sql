/*
CASE 03: Foodie-Fi - Case Study B: Data Analysis Questions

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-3/
*/

--DATA ANALYSIS QUESTIONS:

--QUESTION 1: How many customers has Foodie-Fi ever had?

    SELECT  COUNT(DISTINCT customer_id) AS total_customers
    FROM subscriptions;

--QUESTION 2: What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

    SELECT
    	EXTRACT(MONTH FROM sub.start_date) AS month_num,
    	MONTHNAME(sub.start_date) AS month_name,
    	COUNT(sub.customer_id) AS total_subs
    FROM subscriptions AS sub
    WHERE sub.plan_id = 0
    GROUP BY month_num, month_name
    ORDER BY month_num;

--QUESTION 3: What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

    SELECT 
        pl.plan_id, 
        pl.plan_name, 
        COUNT(sub.customer_id) AS total_subs
    FROM plans AS pl
    JOIN subscriptions AS sub ON sub.plan_id = pl.plan_id
    WHERE sub.start_date >= '2021-01-01'
    GROUP BY pl.plan_id, pl.plan_name
    ORDER BY pl.plan_id;

--QUESTION 4: What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

    SELECT
        COUNT(DISTINCT sub.customer_id) As total_churn,
        ROUND(100.0 * COUNT(sub.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS churn_percentage
    FROM subscriptions AS sub
    WHERE sub.plan_id = 4;

--Explanation: (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) is a subquery to calculate the total amount of customers

--QUESTION 5: How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

    WITH next_sub AS(
	SELECT 
	    customer_id, 
	    plan_id,
	    LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_subscription
	FROM subscriptions
    )

    SELECT
        COUNT(DISTINCT customer_id) AS churned_customers,
        ROUND( 100 * COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) AS churn_percentage
    FROM next_sub
    WHERE plan_id = 0 AND next_subscription = 4;

/*
    Explanations: First there is a subquery using window function LEAD() to obtain the next 'plan_id' after free trial of every client with
    PARTITION BY and order by 'start_date'. Then calculate the percentage with the total number of clients.
*/

--QUESTION 6: What is the number and percentage of customer plans after their initial free trial?

  WITH next_sub AS(
	SELECT
		customer_id,
		plan_id,
		LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_subscription
	FROM subscriptions
    )

    SELECT 
        next_subscription AS plan_id,
        COUNT(customer_id) AS count_customers,
        ROUND( 100 * COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions)) AS percentage
    FROM next_sub
    WHERE next_subscription IS NOT NULL AND plan_id = 0
    GROUP BY next_subscription
    ORDER BY next_subscription;  

--QUESTION 7: What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH next_dates AS(
    SELECT
	customer_id,
	plan_id,
        start_date,
	LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_date
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
    )

    SELECT 
        plan_id,
        COUNT(DISTINCT customer_id) AS total_customers,
        ROUND(100.0 * COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percentage
    FROM next_dates
    WHERE next_date IS NULL
    GROUP BY plan_id;

/*
--Explanation: the subquery 'next_dates' calculates the next 'start_date' of every subscription until 2020-12-31. The main query sets the 
condition for filtering only the active subscriptions and calculates the percentage.
*/

--QUESTION 8: How many customers have upgraded to an annual plan in 2020?

    SELECT 
	COUNT(DISTINCT customer_id) AS annual_customers
    FROM subscriptions
    WHERE plan_id = 3 AND start_date <= '2020-12-31';

--QUESTION 9: How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH trial_plan AS (
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM subscriptions
  WHERE plan_id = 0
), annual_plan AS (
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM subscriptions
  WHERE plan_id = 3
)

    SELECT 
	    ROUND(AVG(DATEDIFF(annual_date, trial_date))) AS average_days_to_annual_plan
    FROM trial_plan
    JOIN annual_plan ON trial_plan.customer_id = annual_plan.customer_id;

/*
--Explanation: First subquery calculates the free trial'start_date' for every customer and the second one the 'start_date' of the upgrade to
annual plan. The main query calculates de avegrage difference between this two dates.
*/

--QUESTION 10: Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH trial_plan AS (
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM subscriptions
  WHERE plan_id = 0
), annual_plan AS (
  SELECT 
	customer_id, 
	start_date AS annual_date
  FROM subscriptions
  WHERE plan_id = 3
), day_difference AS (
  SELECT
	trial_plan.customer_id,
	DATEDIFF(annual_date, trial_date) AS day_diff
   FROM trial_plan
   JOIN annual_plan ON trial_plan.customer_id = annual_plan.customer_id
)

    SELECT
    customer_id,
        CASE 
            WHEN day_diff > 0 AND day_diff <= 30 THEN '0-30 days'
            WHEN day_diff > 30 AND day_diff <= 60 THEN '30-60 days'
            WHEN day_diff > 60 AND day_diff <= 90 THEN '60-90 days'
            ELSE 'more than 90 days'
        END AS day_clasification
    FROM day_difference;

/* 
--Explanation: First subquery calculates the free trial'start_date' for every customer and the second one the 'start_date' of the upgrade to
annual plan. The third subquery calculates the days difference between the begining of the free trial and the upgrade to annual plan. Main query
make a clasification of every annual subscriber with a CASE.
*/

--QUESTION 11: How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH next_sub AS(
	SELECT
		customer_id,
		plan_id,
		LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_subscription
	FROM subscriptions 
    	WHERE EXTRACT(YEAR FROM start_date) = 2020
    )

SELECT 
	COUNT(DISTINCT customer_id) total_downgrade
FROM next_sub
WHERE plan_id = 2 AND next_subscription = 1;

--Answer: 0 customers downgraded in 2020 from pro monthly to basic monthly subscription.
