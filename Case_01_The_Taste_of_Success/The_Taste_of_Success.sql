/*
CASE 01: The Taste of Success

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-1/
*/

-- QUESTION 1: What is the total amount each customer spent at the restaurant?

    SELECT SUM(menu.price) as total_spent, sales.customer_id
    FROM menu 
    JOIN sales ON (menu.product_id = sales.product_id)
    GROUP BY sales.customer_id
    ORDER BY sales.customer_id;

-- QUESTION 2: How many days has each customer visited the restaurant?

    SELECT COUNT(DISTINCT(sales.order_date)) AS total_days, sales.customer_id
    FROM sales
    GROUP BY customer_id
    ORDER BY total_days;

-- QUESTION 3: What was the first item from the menu purchased by each customer?

    SELECT menu.product_name, sales.customer_id, sales.order_date
    FROM sales
    JOIN menu ON (menu.product_id = sales.product_id)
    WHERE order_date = (SELECT MIN(order_date) FROM sales) --select the first order with this condition

-- QUESTION 4: What is the most purchased item on the menu and how many times was it purchased by all customers?

    SELECT menu.product_name, COUNT(sales.product_id) AS times_ordered
    FROM menu
    JOIN sales ON (menu.product_id = sales.product_id)
    GROUP BY menu.product_name
    ORDER BY times_ordered DESC
    LIMIT 1;

-- QUESTION 5: Which item was the most popular for each customer?

    SELECT menu.product_name, COUNT(*) AS total_ordered, sales.customer_id
    FROM menu
    JOIN sales ON menu.product_id = sales.product_id
    GROUP BY sales.customer_id, menu.product_name;

--QUESTION 6: Which item was purchased first by the customer after they became a member?

    WITH ranking_orders AS(
        SELECT sales.customer_id, sales.order_date, menu.product_name, members.join_date,
            DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS ranking 
        FROM sales
        JOIN menu ON menu.product_id = sales.product_id
        JOIN members ON members.customer_id = sales.customer_id
        WHERE sales.order_date >= members.join_date
    )

    SELECT customer_id, product_name, order_date, join_date
    FROM ranking_orders
    WHERE ranking = 1; 

/* 
    Explicación:

    1- Subconsulta que mediante una función de ventana y una partición crea una columna 'ranking' que clasifica los pedidos de cada cliente realizados después de convertirse en miembro del club.
    2- Mostrar el premer pedido ('ranking' = 1) que realizó cada cliente.

*/

--QUESTION 7: Which item was purchased just before the customer became a member?

  WITH ranking_orders AS(
        SELECT sales.customer_id, sales.order_date, menu.product_name, members.join_date,
            DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS ranking 
        FROM sales
        JOIN menu ON menu.product_id = sales.product_id
        JOIN members ON members.customer_id = sales.customer_id
        WHERE sales.order_date < members.join_date
    )

    SELECT customer_id, product_name, order_date, join_date
    FROM ranking_orders
    WHERE ranking = 1; 

/* 
    Explicación:

    Esta es similar a la anterior salvo que ahora como queremos el último pedido realizado por cada cliente antes de hacerse miembro, en la subconsulta seleccionamos en el WHERE los pedidos antes de 'join_date' y 
    el 'ranking' generado con la función de ventana lo ordenamos de forma descendiente (DESC) para que el último pedido sea el primero antes de ser miembro.
    Luego en la consulta principal es igual a la anterior.

*/

--QUESTION 8: What is the total items and amount spent for each member before they became a member?

    SELECT sales.customer_id, COUNT(sales.product_id) AS total_orders,
        SUM(menu.price) AS total_spent
    FROM sales
    JOIN menu ON menu.product_id = sales.product_id
    JOIN members ON members.customer_id = sales.customer_id
    WHERE sales.order_date < members.join_date
    GROUP BY sales.customer_id
    ORDER BY sales.customer_id;

--QUESTION 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

    SELECT sales.customer_id,
        SUM(CASE WHEN menu.product_name = 'sushi' THEN menu.price*20 ELSE menu.price*10 END) AS total_points
    FROM sales
    JOIN menu ON menu.product_id = sales.product_id
    JOIN members ON members.customer_id = sales.customer_id
    WHERE sales.order_date >= members.join_date
    GROUP BY sales.customer_id
    ORDER BY sales.customer_id;

--QUESTION 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

    WITH dates AS(
        SELECT customer_id, join_date,
            join_date + INTERVAL 6 DAY AS end_double_points_week,
            STR_TO_DATE('2021-01-31', '%Y-%m-%d') AS last_date
        FROM members
    )

    SELECT sales.customer_id, 
        SUM(CASE WHEN sales.order_date <= dates.end_double_points_week THEN menu.price*20
            WHEN menu.product_name = 'sushi' THEN menu.price*20 ELSE menu.price*10 END) AS total_points
    FROM sales
    JOIN menu ON menu.product_id = sales.product_id
    JOIN members ON members.customer_id = sales.customer_id
    JOIN dates ON dates.customer_id = sales.customer_id
    WHERE sales.order_date >= members.join_date AND sales.order_date <= dates.last_date
    GROUP BY sales.customer_id
    ORDER BY sales.customer_id;

/* 
    Explicación:

    1- Subconsulta para crear un campo que determine el final del beneficio de doble acumulación de puntos 'end_double_points_week' y otro campo con la fecha límite para recopilar los puntos acumulados 'last_date'.
    2- Cálculo de los puntos acumulados con una función CASE que nos permite distinguir entre pedidos realizados dentro de la semana de doble puntuación y fuera, donde los puntos acumulados varían según el tipo de 
    comida pedida. Por último en el WHERE acotamos las fechas de los pedidos que son válidas, es decir, después de hacerte miembro 'join_date' y hasta el final del periodo de conteo de puntos 'last_date'.

*/