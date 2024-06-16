-- Pizza Runner Data Cleaning and Exploration

USE pizza_runner;

-- customer_orders table

-- blanks and 'null' instead of NULL

UPDATE customer_orders
SET exclusions = null
WHERE exclusions = '' OR exclusions = 'null';

UPDATE customer_orders
SET extras = null
WHERE extras = '' OR extras = 'null';

-- look for duplicates
-- no unique id column to identify duplicates
SELECT *,
ROW_NUMBER() OVER() AS row_num
FROM customer_orders;

SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;

-- runner_orders table
SELECT * FROM runner_orders;

-- deal with blanks and "null"

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = 'null' OR cancellation = '';

-- clean up distance and duration fields

-- distance - get rid of 'km' and TRIM
UPDATE runner_orders
SET distance = TRIM(TRAILING 'km' FROM distance);
UPDATE runner_orders
SET distance = RTRIM(distance);

-- duration get rid of 'minutes' 'minute' and 'min'

UPDATE runner_orders
SET duration = TRIM(TRAILING 'minute' FROM duration);

-- modify distance and duration > INT
ALTER TABLE runner_orders
MODIFY COLUMN duration INT;

-- runners table
SELECT * FROM runners;