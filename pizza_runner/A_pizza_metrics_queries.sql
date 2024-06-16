USE pizza_runner_v2;

-- How many pizzas were ordered?

SELECT 
	COUNT(order_item_id) AS total_pizzas_ordered
FROM order_items AS oi
JOIN orders AS o
ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL;

-- How many unique customer orders were made?

SELECT 
COUNT(order_id) AS total_unique_orders
FROM orders;

-- How many successful orders were delivered by each runner?

SELECT 
d.runner_id,
COUNT(o.order_id) AS num_orders_delivered
FROM orders AS o
JOIN deliveries AS d
ON o.order_id = d.order_id
WHERE o.cancellation IS NULL
GROUP BY d.runner_id;

-- How many of each type of pizza was delivered?
SELECT
	p.pizza_name,
    COUNT(oi.order_item_id) AS pizzas_delivered
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN pizzas p
	ON oi.pizza_id = p.pizza_id 
WHERE o.cancellation IS NULL
GROUP BY p.pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	o.customer_id,
	p.pizza_name,
	COUNT(oi.order_id) AS num_ordered
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN pizzas p
	ON oi.pizza_id = p.pizza_id
GROUP BY o.customer_id, p.pizza_name
ORDER BY o.customer_id, p.pizza_name;

-- What was the maximum number of pizzas delivered in a single order?

SELECT
	oi.order_id,
	COUNT(oi.order_id) AS num_pizzas_delivered
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY oi.order_id
ORDER BY COUNT(oi.order_id) DESC LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
	o.customer_id,
	SUM(CASE WHEN amendment_id IS NULL THEN 1 ELSE 0 END) AS no_changes,
	SUM(CASE WHEN amendment_id IS NOT NULL THEN 1 ELSE 0 END) AS changes
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
LEFT JOIN order_amendments oa
ON oi.order_item_id = oa.order_item_id
WHERE o.cancellation IS NULL
GROUP BY o.customer_id
ORDER BY o.customer_id;


-- How many pizzas were delivered that had both exclusions and extras?

SELECT 
COUNT(DISTINCT oa.order_item_id) AS pizzas_with_extras_and_exclusions
FROM order_amendments oa
JOIN order_items oi
ON oa.order_item_id = oi.order_item_id
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY oa.order_item_id
HAVING COUNT(DISTINCT oa.amendment_type) > 1
;



-- What was the total volume of pizzas ordered for each hour of the day?

SELECT
HOUR(o.order_time) AS hour,
COUNT(oi.order_item_id) AS num_pizzas_ordered
FROM 
orders AS o
JOIN order_items AS oi
ON o.order_id = oi.order_id
GROUP BY HOUR(o.order_time)
ORDER BY HOUR(o.order_time) ASC;

-- What was the volume of orders for each day of the week?

SELECT 
DAYNAME(o.order_time) AS day,
COUNT(o.order_id) AS num_orders
FROM orders AS o
GROUP BY DAYNAME(o.order_time)
ORDER BY num_orders DESC;
