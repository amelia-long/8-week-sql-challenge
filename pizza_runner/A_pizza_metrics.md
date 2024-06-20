# A. Pizza Metrics

## 1. How many pizzas were ordered?

```sql
SELECT 
  COUNT(order_item_id) AS total_pizzas_ordered
FROM order_items AS oi
JOIN orders AS o
ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL;
```

## 2. How many unique customer orders were made?

```sql
SELECT 
  COUNT(order_id) AS total_unique_orders
FROM orders;
```

## 3. How many successful orders were delivered by each runner?

```sql
SELECT 
  d.runner_id,
  COUNT(o.order_id) AS num_orders_delivered
FROM orders AS o
JOIN deliveries AS d
  ON o.order_id = d.order_id
WHERE o.cancellation IS NULL
GROUP BY d.runner_id;
```

## 4. How many of each type of pizza was delivered?

```sql
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
```

## 5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
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
```

## 6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT
  oi.order_id,
  COUNT(oi.order_id) AS num_pizzas_delivered
FROM order_items oi
JOIN orders o
  ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY oi.order_id
ORDER BY COUNT(oi.order_id) DESC LIMIT 1;
```

## 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
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
```
## 8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT 
  COUNT(DISTINCT oa.order_item_id) AS pizzas_with_extras_and_exclusions
FROM order_amendments oa
JOIN order_items oi
  ON oa.order_item_id = oi.order_item_id
JOIN orders o
  ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY oa.order_item_id
HAVING COUNT(DISTINCT oa.amendment_type) > 1;
```
## 9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT
  HOUR(o.order_time) AS hour,
  COUNT(oi.order_item_id) AS num_pizzas_ordered
FROM 
orders AS o
JOIN order_items AS oi
  ON o.order_id = oi.order_id
GROUP BY HOUR(o.order_time)
ORDER BY HOUR(o.order_time) ASC;
```
## 10. What was the volume of orders for each day of the week?

```sql
SELECT 
  DAYNAME(o.order_time) AS day,
  COUNT(o.order_id) AS num_orders
FROM orders AS o
GROUP BY DAYNAME(o.order_time)
ORDER BY num_orders DESC;
```
