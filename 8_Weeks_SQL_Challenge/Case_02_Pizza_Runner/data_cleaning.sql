
-- LIMPIEZA DE DATOS PREVIA AL ANÁLISIS:

/* 
    Debemos limpiar las tablas 'customer_orders' y 'runner_orders' ya que contienen datos nulos (NULL). Además es necesario retocar algunos datos que deberían ser números y están
    en un formato incorrecto. Por último también cambiaremos el tipo de dato de algunos campos para darle consistencia a las tablas.
*/

--LIMPIEZA DE LA TABLA 'customer_order'

-- Eliminar los valores NULL y null de las columnas 'exceptions' y 'extras':

    UPDATE customer_orders
    SET exclusions = ' ' 
    WHERE exclusions IS NULL OR exclusions LIKE 'null';

    UPDATE customer_orders
    SET extras = ' ' 
    WHERE extras IS NULL OR extras LIKE 'null';

--Con estas dos acciones ya tenemos la tabla 'customer_orders' preparada para el análisis.


--LIMPIEZA DE LA TABLA 'runner_order'

-- Eliminar los valores NULL y null de las columnas 'pickup_time', 'distance', 'duration' y 'cancellation':

    UPDATE runner_orders
    SET pickup_time = ' ' 
    WHERE pickup_time IS NULL OR pickup_time LIKE 'null';

    UPDATE runner_orders
    SET distance = ' ' 
    WHERE distance IS NULL OR distance LIKE 'null';

    UPDATE runner_orders
    SET duration = ' ' 
    WHERE duration IS NULL OR duration LIKE 'null';

    UPDATE runner_orders
    SET cancellation = ' ' 
    WHERE cancellation IS NULL OR cancellation LIKE 'null';

--Formatear las columna 'distance' y 'duration' para que todos los datos sean numéricos:

    UPDATE runner_orders
    SET distance = REPLACE(distance, 'km', '')
    WHERE distance LIKE '%km'; 

    ALTER TABLE runner_orders
    MODIFY COLUMN distance FLOAT;

--Formatear las columna 'duration' para que todos los datos sean numéricos:

    UPDATE runner_orders
    SET duration = REPLACE(duration, 'mins', '')
    WHERE duration LIKE '%mins'; 

    UPDATE runner_orders
    SET duration = REPLACE(duration, 'minute', '')
    WHERE duration LIKE '%minute'; 

    UPDATE runner_orders
    SET duration = REPLACE(duration, 'minutes', '')
    WHERE duration LIKE '%minutes'; 

    ALTER TABLE runner_orders
    MODIFY COLUMN duration INT;