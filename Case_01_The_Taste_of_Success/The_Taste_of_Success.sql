/*
CASE 01: The Taste of Success

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-1/
*/

-- Question 1: What is the total amount each customer spent at the restaurant?

    SELECT SUM(menu.price) as total_spent, sales.customer_id
    FROM menu 
    JOIN sales ON (menu.product_id = sales.product_id)
    GROUP BY sales.customer_id
    ORDER BY sales.customer_id;

-- Question 2: How many days has each customer visited the restaurant?

    SELECT COUNT(DISTINCT(sales.order_date)) AS total_days, sales.customer_id
    FROM sales
    GROUP BY customer_id
    ORDER BY total_days;

-- Question 3: What was the first item from the menu purchased by each customer?

    SELECT menu.product_name, sales.customer_id, sales.order_date
    FROM sales
    JOIN menu ON (menu.product_id = sales.product_id)
    WHERE order_date = (SELECT MIN(order_date) FROM sales) --select the first order with this condition

-- Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?

    SELECT menu.product_name, COUNT(sales.product_id) AS times_ordered
    FROM menu
    JOIN sales ON (menu.product_id = sales.product_id)
    GROUP BY menu.product_name
    ORDER BY times_ordered DESC
    LIMIT 1;

-- Question 5: Which item was the most popular for each customer?

    SELECT menu.product_name, COUNT(*) AS total_ordered, sales.customer_id
    FROM menu
    JOIN sales ON menu.product_id = sales.product_id
    GROUP BY sales.customer_id, menu.product_name;

--Question 6: Which item was purchased first by the customer after they became a member?