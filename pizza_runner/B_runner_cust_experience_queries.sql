-- B. Runner and Customer Experience
USE pizza_runner_v2;

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	YEAR(registration_date) AS year,
    WEEKOFYEAR(registration_date) AS week_of_year,
	COUNT(runner_id) AS num_runners_registered
FROM runners
GROUP BY WEEKOFYEAR(registration_date), YEAR(registration_date);


-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT
	d.runner_id,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,o.order_time,d.pickup_time))) AS avg_pickup_time_mins
FROM deliveries AS d
JOIN orders o
ON d.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY d.runner_id;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
o.order_id,
COUNT(oi.order_item_id) AS num_pizzas,
TIMESTAMPDIFF(MINUTE,o.order_time,d.pickup_time) AS prep_time
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN deliveries d
ON o.order_id = d.order_id
WHERE o.cancellation IS NULL
GROUP BY o.order_id, prep_time
ORDER BY num_pizzas DESC;

-- What was the average distance travelled for each customer?
SELECT
o.customer_id,
ROUND(AVG(d.distance_km)) AS avg_distance,
COUNT(d.distance_km) AS num_trips
FROM orders o
JOIN deliveries d
ON o.order_id = d.order_id
WHERE o.cancellation IS NULL
GROUP BY o.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT
TIMEDIFF(MAX(TIMEDIFF(d.delivery_time,o.order_time)),MIN(TIMEDIFF(d.delivery_time,o.order_time))) AS long_short_time_diff
FROM deliveries AS d
JOIN orders AS o
ON d.order_id = o.order_id;


-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	d.runner_id,
    ROUND(AVG((d.distance_km/(MINUTE(TIMEDIFF(d.delivery_time,d.pickup_time)))) * 60),2) AS avg_speed
FROM deliveries AS d
JOIN orders AS o
ON d.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY d.runner_id;



-- What is the successful delivery percentage for each runner?

SELECT
d.runner_id,
COUNT(d.order_id) AS total_orders,
COUNT(o.cancellation) AS total_cancelled,
ROUND(((COUNT(d.order_id) - COUNT(o.cancellation))/COUNT(d.order_id)) * 100) AS percentage_delivered
FROM deliveries AS d
JOIN orders AS o
ON d.order_id = o.order_id
GROUP BY runner_id;

-- uh oh, I haven't assigned a runner to cancelled deliveries - insert rows from pizza_runner v1
INSERT INTO deliveries (order_id, runner_id)
SELECT order_id, runner_id
FROM pizza_runner.runner_orders
WHERE cancellation IS NOT NULL;