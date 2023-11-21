/*
CASE 02: Pizza Runne - Runner and Customer Experience

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-2/
*/

--RUNNER AND CUSTOMER EXPERIENCE QUESTIONS:

--QUESTION 1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

    SELECT WEEK(registration_date, 5) AS week_number, 
       COUNT(runner_id) AS total_runner_registration
    FROM runners
    GROUP BY week_number
    ORDER BY week_number;

/*
    Explicación: 
    
    La función WEEK() devuelve el número de semana de un campo fecha, el segundo parámetro es para indicar en que día de la semana se desea que esta comience. Por defecto empieza en domingo (0), como queremos que 
    nuestra semana comience el 2021-01-01, que es viernes, deberemos poenr el 5.

*/

--QUESTION 2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

    WITH tmp AS(
	SELECT DISTINCT 
		customer_orders.order_id, runner_orders.runner_id,
		customer_orders.order_time, runner_orders.pickup_time,
		TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time) AS time_in_minutes
	FROM runner_orders
    JOIN customer_orders ON customer_orders.order_id = runner_orders.order_id
	WHERE runner_orders.cancellation IS NOT NULL
    )
    SELECT runner_id,
        ROUND(AVG(time_in_minutes),2) AS average_time
    FROM tmp
    GROUP BY runner_id
    ORDER BY runner_id;

/*
    Explicación: 
    
    1- Subconsulta para calcular el tiempo entre que se recibe el pedido 'order_time' y el tiempo en que el rider lo retira de la pizzería para repartirlo 'pickup_time'. Usamos la cláusula DISTINCT para que solo se
    tengan en cuenta una vez cada pedido.
    2- Cálculo del tiempo promedio por rider con la función AVG() redondeada a dos decimales.

*/

--QUESTION 3: Is there any relationship between the number of pizzas and how long the order takes to prepare?

   WITH tmp AS(
	SELECT COUNT(customer_orders.order_id) AS total_items,
		TIMESTAMPDIFF(MINUTE, customer_orders.order_time, runner_orders.pickup_time) AS time_in_minutes
	FROM runner_orders
    JOIN customer_orders ON customer_orders.order_id = runner_orders.order_id
	WHERE runner_orders.cancellation = IS NOT NULL
	GROUP BY runner_orders.pickup_time, customer_orders.order_time
    )
    SELECT total_items,
        ROUND(AVG(time_in_minutes),2) AS average_time
    FROM tmp
    GROUP BY total_items;

/*
    RESULTADOS QUERY: Si existe relación, a mayor número de pizzas en el pedido mayor es el tiempo de preparación.
    total_items | average_time 
    ----------------------------
         1            12.0 
         2            18.0 
         3            29.0

*/

--QUESTION 4: What was the average distance travelled for each customer?

    SELECT customer_orders.customer_id,
        ROUND(AVG(runner_orders.distance),2) AS average_distance
    FROM customer_orders
    JOIN runner_orders ON runner_orders.order_id = customer_orders.order_id
    WHERE runner_orders.distance IS NOT NULL
    GROUP BY customer_orders.customer_id;

--QUESTION 5: What was the difference between the longest and shortest delivery times for all orders

    SELECT MAX(duration) - MIN(duration) AS time_diff
    FROM runner_orders;

--QUESTION 6: What was the average speed for each runner for each delivery and do you notice any trend for these values?

    SELECT order_id, runner_id, distance, duration,
	ROUND(AVG(distance/duration*60),2) AS average_speed
    FROM runner_orders
    WHERE distance IS NOT NULL
    GROUP BY order_id, runner_id, distance, duration;



--QUESTION 7: What is the successful delivery percentage for each runner?

    SELECT runner_id,
        COUNT(distance) AS delivered,
        COUNT(order_id) AS total_orders,
        ROUND(100 * COUNT(distance) / COUNT(order_id),2)  AS success_percentage
    FROM runner_orders
    GROUP BY runner_id;