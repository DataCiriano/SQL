/*
CASE 02: Pizza Runne - Pizza Metrics

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-2/
*/

--PIZZA METRICS QUESTIONS:

--QUESTION 1: How many pizzas were ordered?

    SELECT COUNT(*) AS total_pizzas_ordered
    FROM customer_orders;

--QUESTION 2: How many unique customer orders were made?

    SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
    FROM customer_orders;

--QUESTION 3: How many successful orders were delivered by each runner?

    SELECT runner_id, COUNT(order_id) AS total_orders 
    FROM runner_orders
    WHERE cancellation = ''
    GROUP BY runner_id;

--QUESTION 4: How many of each type of pizza was delivered?

    SELECT pizza_names.pizza_name, COUNT(customer_orders.pizza_id) AS total_ordered
    FROM customer_orders
    JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
    JOIN runner_orders ON runner_orders.order_id = customer_orders.order_id
    WHERE runner_orders.cancellation = ''
    GROUP BY pizza_names.pizza_name;

--QUESTION 5: How many Vegetarian and Meatlovers were ordered by each customer?

    SELECT customer_orders.customer_id,
	SUM(CASE WHEN pizza_names.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS total_Meatlovers,
    SUM(CASE WHEN pizza_names.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) as total_Vegetarian
    FROM customer_orders
    JOIN pizza_names ON pizza_names.pizza_id = customer_orders.pizza_id
    GROUP BY customer_orders.customer_id
    ORDER BY customer_orders.customer_id;

--QUESTION 6: What was the maximum number of pizzas delivered in a single order?

    WITH tmp AS(
	SELECT customer_orders.order_id, 
		COUNT(customer_orders.pizza_id) AS total_pizzas
	FROM customer_orders
    JOIN runner_orders ON runner_orders.order_id = customer_orders.order_id
	WHERE runner_orders.cancellation = ''
    GROUP BY customer_orders.order_id
    )
    SELECT MAX(total_pizzas) AS max_pizzas_delivered
    FROM tmp;

--QUESTION 7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

    SELECT customer_orders.customer_id,
	SUM(CASE WHEN customer_orders.exclusions != '' OR customer_orders.extras != '' THEN 1 ELSE 0 END) AS total_pizzas_changed,
    SUM(CASE WHEN customer_orders.exclusions = '' AND customer_orders.extras = '' THEN 1 ELSE 0 END) AS total_pizzas_unchanged
    FROM customer_orders
    JOIN runner_orders ON runner_orders.order_id = customer_orders.order_id
    WHERE runner_orders.cancellation = ''
    GROUP BY customer_orders.customer_id;

--QUESTION 8: How many pizzas were delivered that had both exclusions and extras?

    SELECT SUM(CASE WHEN customer_orders.exclusions != '' AND customer_orders.extras != '' THEN 1 ELSE 0 END) AS total_pizzas_w_exclusions_and_extras
    FROM customer_orders
    JOIN runner_orders ON runner_orders.order_id = customer_orders.order_id
    WHERE runner_orders.distance = '';

--QUESTION 9: What was the total volume of pizzas ordered for each hour of the day?

    SELECT EXTRACT(HOUR FROM customer_orders.order_time) AS order_hour,
	COUNT(customer_orders.order_id) AS total_pizzas
    FROM  customer_orders
    GROUP BY order_hour
    ORDER BY order_hour;

--QUESTION 10: What was the volume of orders for each day of the week?

    SELECT DAYNAME(customer_orders.order_time) AS week_day,
	COUNT(customer_orders.order_id) AS total_pizzas
    FROM  customer_orders
    GROUP BY week_day
    ORDER BY week_day;