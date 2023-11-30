/*
CASE 02: Pizza Runne - Pricing and Rating

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-2/
*/

--PRICING AND RATING QUESTIONS:

--QUESTION 1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?  

    SELECT CONCAT(SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END), '$') AS total_revenue
    FROM customer_orders
    INNER JOIN pizza_names USING (pizza_id)
    INNER JOIN runner_orders USING (order_id)
    WHERE runner_orders.distance > 0;

--QUESTION 2: What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

    WITH pizza_revenue As(
        SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS total_revenue
        FROM customer_orders
        INNER JOIN pizza_names USING (pizza_id)
        INNER JOIN runner_orders USING (order_id)
        WHERE runner_orders.distance > 0
    ),
    extras_charge AS(
        SELECT COUNT(extras) AS total_charge
        FROM pizza_exclusions_extras AS pee
        INNER JOIN runner_orders AS ro ON pee.order_id = ro.order_id
        WHERE pee.extras IS NOT NULL AND ro.distance > 0
    )

    SELECT CONCAT(pizza_revenue.total_revenue + extras_charge.total_charge, '$') AS total
    FROM pizza_revenue, extras_charge;

/* 
     Explicación:

     1-Dos subconsultas, la primera para calcular el coste de las pizzas según sean Meat Lovers o Vegetarian y la segunda para calcular el coste adicional por los extras.
     2-Sumar los dos cálculos para obtener el beneficio total.
    
*/

/*QUESTION 3: The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for 
this new table and insert your own data for ratings for each successful customer order between 1 to 5.*/

    DROP TABLE IF EXISTS runner_rating;

    CREATE TABLE runner_rating (order_id INTEGER, rating INTEGER, review VARCHAR(100)) ;

    -- Order 6 and 9 were cancelled
    INSERT INTO runner_rating
    VALUES ('1', '3', 'Correct service'),
        ('2', '1', 'Absolutely terrible service, never ordering again!'),
        ('3', '4', 'Good service, satisfied with the delivery'),
        ('4', '2','Service needs improvement, took too long...'),
        ('5', '2', 'Poor service, significant room for improvement'),
        ('7', '5', 'Outstanding service, exceeded expectations!'),
        ('8', '4', 'Good enough'),
        ('10', '5', 'Great service and delicious pizza');

    SELECT *
    FROM runner_rating;

/*QUESTION 4: Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
    customer_id
    order_id
    runner_id
    rating
    order_time
    pickup_time
    Time between order and pickup
    Delivery duration
    Average speed
    Total number of pizzas*/

    SELECT co.customer_id,
       co.order_id,
       ro.runner_id,
       rr.rating,
       co.order_time,
       ro.pickup_time,
       TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS time_between_order_and_pickup,
       ro.duration AS delivery_duration,
       round(ro.distance*60/ro.duration, 2) AS average_speed,
       count(co.pizza_id) AS total_number_pizza
    FROM customer_orders AS co
    INNER JOIN runner_orders AS ro USING (order_id)
    INNER JOIN runner_rating AS rr USING (order_id)
    GROUP BY 
        co.customer_id,
        co.order_id,
        ro.runner_id,
        rr.rating,
        co.order_time,
        ro.pickup_time,
        time_between_order_and_pickup,
        delivery_duration,
        average_speed;

/*QUESTION 5: If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after
these deliveries?*/

    WITH pizza_revenue As(
        SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS total_revenue
        FROM customer_orders
        INNER JOIN pizza_names USING (pizza_id)
        INNER JOIN runner_orders USING (order_id)
        WHERE runner_orders.distance > 0
    ),
    delivery_cost AS(
        SELECT ROUND(SUM(distance*0.30), 2) AS total
        FROM runner_orders AS ro
        WHERE ro.distance > 0
    )

    SELECT CONCAT(pizza_revenue.total_revenue - delivery_cost.total, '$') AS total
    FROM pizza_revenue, delivery_cost;

/* 
     Explicación:

     1-Dos subconsultas, la primera para calcular el coste de las pizzas según sean Meat Lovers o Vegetarian y la segunda para calcular el coste total por los km recorridos.
     2-Restar al coste de las pizzas los costes del reparto.
    
*/
