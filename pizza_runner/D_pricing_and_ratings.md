# D. Pricing and Ratings

## If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT
  SUM(p.pizza_price) AS total_sales
FROM orders o
JOIN order_items oi
  ON o.order_id = oi.order_id
JOIN pizzas p
  ON oi.pizza_id = p.pizza_id
WHERE cancellation IS NULL;
```

## What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

```sql
WITH extras AS
(
SELECT 
  SUM(CASE WHEN oa.amendment_type = 1 THEN t.topping_price ELSE 0 END) AS extras_price
FROM order_amendments oa
RIGHT JOIN order_items oi
	ON oa.order_item_id = oi.order_item_id
JOIN toppings t
	ON oa.topping_id = t.topping_id
JOIN orders o
	ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL
),
pizza AS
(
SELECT
  SUM(p.pizza_price) AS pizza_price
FROM order_items oi
JOIN orders o
	ON oi.order_id = o.order_id
JOIN pizzas p
	ON oi.pizza_id = p.pizza_id
WHERE o.cancellation IS NULL
)
SELECT 
  pizza.pizza_price + extras.extras_price AS total_revenue
FROM extras, pizza;
```

## The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

In my schema redesign I created a deliveries table and added a rating column to this.

## Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
  - customer_id
  - order_id
  - runner_id
  - rating
  - order_time
  - pickup_time
  - Time between order and pickup
  - Delivery duration
  - Average speed
  - Total number of pizzas

```sql
WITH items_count AS
(
SELECT
  oi.order_id,
  COUNT(oi.order_item_id) AS num_items
FROM order_items oi
JOIN orders o
  ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY oi.order_id
),
average_speed AS
(
SELECT 
  d.runner_id,
  ROUND(AVG((d.distance_km/(MINUTE(TIMEDIFF(d.delivery_time,d.pickup_time)))) * 60),2) AS avg_speed
FROM deliveries AS d
JOIN orders AS o
  ON d.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY d.runner_id
)
SELECT
  o.order_id,
  o.customer_id,
  d.runner_id,
  o.order_time,
  d.pickup_time,
  d.delivery_time,
  TIMEDIFF(d.pickup_time,o.order_time) AS order_to_pickup_duration,
  TIMEDIFF(d.delivery_time,d.pickup_time) AS pickup_to_delivery_duration,
  TIMEDIFF(d.delivery_time,o.order_time) AS order_to_delivery_duration,
  ROUND((d.distance_km/(MINUTE(TIMEDIFF(d.delivery_time,d.pickup_time))) * 60),2) AS speed,
  average_speed.avg_speed AS avg_speed,
  d.distance_km,
  d.rating,
  items_count.num_items AS total_num_pizzas
FROM orders o
JOIN deliveries d
	ON o.order_id = d.order_id
JOIN items_count
	ON o.order_id = items_count.order_id
JOIN average_speed
	ON d.runner_id = average_speed.runner_id
WHERE o.cancellation IS NULL;
```
## If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql
WITH pizza_total AS
(
SELECT
  SUM(p.pizza_price) AS tot
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN pizzas p
	ON oi.pizza_id = p.pizza_id
WHERE cancellation IS NULL
),
runner_pay AS
(
SELECT
  SUM(distance_km) * 0.3 AS tot
FROM deliveries d
JOIN orders o
  ON d.order_id = o.order_id
WHERE o.cancellation IS NULL
)
SELECT
  ROUND(pizza_total.tot - runner_pay.tot,2) AS revenue_after_runner_pay
FROM pizza_total,runner_pay;
```
