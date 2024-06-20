# B. Runner and Customer Experience

## How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT 
  YEAR(registration_date) AS year,
  WEEKOFYEAR(registration_date) AS week_of_year,
  COUNT(runner_id) AS num_runners_registered
FROM runners
GROUP BY WEEKOFYEAR(registration_date), YEAR(registration_date);
```

Output: I couldn't work out how to get around MySQL's insistence upon designating the first week of the year as number 53.

<img width="297" alt="Screenshot 2024-06-20 at 16 01 54" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/284c4f07-be9b-474d-8b76-6429457bc22d">


## What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
SELECT
  d.runner_id,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE,o.order_time,d.pickup_time))) AS avg_pickup_time_mins
FROM deliveries AS d
JOIN orders o
  ON d.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY d.runner_id;
```

Output: Average pickup times for Runner 1 was 14 minutes, Runner 2 was 20 minutes, and Runner 3 was 10 minutes.

## Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
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
```

Output: the higher the number of pizzas in the order, the longer it takes to prepare with a time per pizza of on average 10 minutes.

<img width="249" alt="Screenshot 2024-06-20 at 16 04 08" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/7056e9c7-0055-437e-889b-562b17ebccc9">


## What was the average distance travelled for each customer?

```sql
SELECT
  o.customer_id,
  ROUND(AVG(d.distance_km)) AS avg_distance,
  COUNT(d.distance_km) AS num_trips
FROM orders o
JOIN deliveries d
  ON o.order_id = d.order_id
WHERE o.cancellation IS NULL
GROUP BY o.customer_id;
```

<img width="249" alt="Screenshot 2024-06-20 at 16 05 40" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/c09db930-c505-40e4-9685-d78379a1dfe6">


## What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT
  TIMEDIFF(MAX(TIMEDIFF(d.delivery_time,o.order_time)),MIN(TIMEDIFF(d.delivery_time,o.order_time))) AS long_short_time_diff
FROM deliveries AS d
JOIN orders AS o
  ON d.order_id = o.order_id;
```

Output: 43 minutes, 49 seconds

## What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT 
  d.runner_id,
  d.order_id,
  ROUND(AVG((d.distance_km/(MINUTE(TIMEDIFF(d.delivery_time,d.pickup_time)))) * 60),2) AS avg_speed
FROM deliveries AS d
JOIN orders AS o
  ON d.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY d.runner_id, d.order_id;
```

<img width="201" alt="Screenshot 2024-06-21 at 00 23 45" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/6a770801-ff24-43af-8385-142bf8acae4a">


## What is the successful delivery percentage for each runner?

```sql
SELECT
  d.runner_id,
  COUNT(d.order_id) AS total_orders,
  COUNT(o.cancellation) AS total_cancelled,
  ROUND(((COUNT(d.order_id) - COUNT(o.cancellation))/COUNT(d.order_id)) * 100) AS percentage_delivered
FROM deliveries AS d
JOIN orders AS o
  ON d.order_id = o.order_id
GROUP BY runner_id;
```

Output: Runner 1 delivered 100% of their orders, Runner 2 75% and Runner 3 50%.
