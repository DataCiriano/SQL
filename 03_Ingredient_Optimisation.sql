/*
CASE 02: Pizza Runne - Ingredient Optimisation

    All the info about this Case is in: https://8weeksqlchallenge.com/case-study-2/
*/

--INGREDIENT OPTIMISATION QUESTIONS:

--QUESTION 1: What are the standard ingredients for each pizza?

    CREATE VIEW pizza_recipes_clean AS
        SELECT pizza_id,
            CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1) AS UNSIGNED) AS topping_id
        FROM pizza_recipes
        JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8) AS numbers
            ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) >= n - 1;

    SELECT  pr.pizza_id, pr.topping_id, pt.topping_name
    FROM pizza_recipes_clean AS pr
    JOIN pizza_toppings AS pt ON pt.topping_id = pr.topping_id
    ORDER BY pr.pizza_id;

/* 
    Explicación:

    1- Creación de una vista donde los 'toppings' de la tabla 'pizza_recipes' que se encuentran separados por comas en una cadena de texto, se dividen por filas. Para ello se utiliza 
    la función CAST() y SUBSTRING_INDEX().
        La primera llamada a SUBSTRING_INDEX obtiene todos los toppings hasta el enésimo elemento en una subcadena.
        La segunda llamada a SUBSTRING_INDEX extrae el enésimo topping individual de esa subcadena.
        Esto es necesario porque SUBSTRING_INDEX no proporciona directamente una forma de obtener el enésimo elemento de una cadena delimitada por comas en una sola llamada.

        La función CAST(... AS UNSIGNED) convierte la subcadena resultante a un valor sin signo.
    
    Después se hace un JOIN con una tabla derivada llamada 'numbers'. Esta tabla derivada se crea usando UNION ALL SELECT para generar números del 1 al 8 (hay 8 toppings max en una 
    un pizza).
    La condicón de unión garantiza que solo se seleccionarán toppings hasta el número correspondiente en la tabla derivada. CHAR_LENGTH() se usa para obtener la longitud total de la 
    cadena de toppings y REPLACE() para eliminar todas las comas, y luego comparar con el número n. 

*/

/*
    Otra forma de crear una vista para separar los toppings es mediante REGEXP_SUBSTR() que extrae directamente el enésimo número de la cadena de toppings utilizando la expresión 
    regular [0-9]+, que busca uno o más dígitos. La condición IS NOT NULL en la cláusula ON garantiza que solo se seleccionen las filas donde hay un enésimo número presente.

*/    
    CREATE VIEW pizza_recipes_clean AS
    SELECT pizza_id,
        CAST(REGEXP_SUBSTR(toppings, '[0-9]+', 1, n) AS UNSIGNED) AS topping_id
    FROM pizza_recipes
    JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8) AS numbers
        ON REGEXP_SUBSTR(toppings, '[0-9]+', 1, n) IS NOT NULL;


--QUESTION 2: What was the most commonly added extra?

    CREATE VIEW pizza_exclusions_extras AS
    SELECT order_id, pizza_id,
        CAST(REGEXP_SUBSTR(exclusions, '[0-9]+', 1, n) AS UNSIGNED) AS exclusions,
        CAST(REGEXP_SUBSTR(extras, '[0-9]+', 1, n) AS UNSIGNED) AS extras
    FROM customer_orders
    JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8) AS numbers
        ON REGEXP_SUBSTR(exclusions, '[0-9]+', 1, n) IS NOT NULL OR REGEXP_SUBSTR(extras, '[0-9]+', 1, n) IS NOT NULL;

    SELECT pt.topping_name, COUNT(extras) AS times_added
    FROM pizza_exclusions_extras AS pex
    JOIN pizza_toppings AS pt ON pt.topping_id = pex.extras
    GROUP BY pt.topping_name
    ORDER BY times_added DESC;

/*
    Explicación:

    1- Vista como en la pregunta anterior para separar las exclusiones y los extras cada una en una línea.
    2- Recuento de los extras para saber cual es el más común.

*/

--QUESTION 3: What was the most common exclusion?

    SELECT pt.topping_name, COUNT(exclusions) AS times_excluded
    FROM pizza_exclusions_extras AS pex
    JOIN pizza_toppings AS pt ON pt.topping_id = pex.exclusions
    GROUP BY pt.topping_name
    ORDER BY times_excluded DESC;

--Se usa la vista creada en la pregunta anterior


