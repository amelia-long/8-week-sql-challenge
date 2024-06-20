# C. Ingredient Optimisation

## What are the standard ingredients for each pizza?

```sql
SELECT 
  p.pizza_name,
  GROUP_CONCAT(t.topping_name) AS ingredients
FROM pizza_recipes pr
JOIN pizzas p
  ON pr.pizza_id = p.pizza_id
JOIN toppings t
  ON pr.topping_id = t.topping_id
GROUP BY p.pizza_name;
```

## What was the most commonly added extra?

```sql
SELECT 
  t.topping_name,
  COUNT(oa.topping_id) AS num_extras
FROM order_amendments oa
JOIN toppings t
  ON oa.topping_id = t.topping_id
WHERE oa.amendment_type = 1
GROUP BY t.topping_name
ORDER BY num_extras DESC LIMIT 1;
```

## What was the most common exclusion?

```sql
SELECT 
  t.topping_name,
  COUNT(oa.topping_id) AS num_exclusions
FROM order_amendments oa
JOIN toppings t
  ON oa.topping_id = t.topping_id
WHERE oa.amendment_type = 0
GROUP BY t.topping_name
ORDER BY num_exclusions DESC LIMIT 1;
```
## Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
WITH menu_cte AS
(
SELECT 
  o.order_id,
  oi.order_item_id,
  CONCAT(p.pizza_name," - ") AS pizza_name,
  GROUP_CONCAT(
  CASE
    WHEN oa.amendment_type = 0 THEN CONCAT('NO ', UPPER(t.topping_name))
    WHEN oa.amendment_type = 1 THEN CONCAT('extra ', LOWER(t.topping_name))
    ELSE "no amendments"
  END) AS amendment_type
FROM order_items AS oi
JOIN orders AS o
  ON oi.order_id = o.order_id
JOIN pizzas AS p
  ON oi.pizza_id = p.pizza_id
LEFT JOIN order_amendments AS oa
  ON oi.order_item_id = oa.order_item_id
LEFT JOIN toppings AS t
  ON oa.topping_id = t.topping_id
GROUP BY o.order_id, oi.order_item_id
)
SELECT
  order_id AS order_id,
  order_item_id AS order_item_id,
  CASE WHEN amendment_type IS NOT NULL THEN CONCAT(pizza_name," ",GROUP_CONCAT(amendment_type ORDER BY amendment_type)) ELSE NULL END AS order_description
FROM menu_cte
GROUP BY order_id, order_item_id;
```
## Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql
WITH standard_toppings AS
(
SELECT
  p.pizza_id,
  p.pizza_name,
  GROUP_CONCAT(t.topping_name) AS ingredients
FROM pizza_recipes AS pr
JOIN pizzas AS p
  ON pr.pizza_id = p.pizza_id
JOIN toppings AS t
  ON pr.topping_id = t.topping_id
GROUP BY p.pizza_id, p.pizza_name
),
amendments AS
(
SELECT
  oi.order_item_id,
  oi.pizza_id,
  oa.amendment_type,
  t.topping_name
FROM order_items oi
JOIN order_amendments oa
  ON oi.order_item_id = oa.order_item_id
JOIN toppings t
  ON oa.topping_id = t.topping_id
)
SELECT
  amendments.order_item_id,
  standard_toppings.pizza_name,
  CASE
    WHEN amendments.amendment_type = 0 
    THEN REPLACE(ingredients, SUBSTRING(ingredients,POSITION(amendments.topping_name IN ingredients),(LENGTH(amendments.topping_name)+1)), "")
    ELSE REPLACE(ingredients, SUBSTRING(ingredients,POSITION(amendments.topping_name IN ingredients),LENGTH(amendments.topping_name)), CONCAT("x2 ",amendments.topping_name)) 
  END AS item_detail,
  CONCAT(amendments.amendment_type," ",amendments.topping_name) as amendments
FROM standard_toppings
JOIN amendments USING (pizza_id);
```
## What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
WITH total_toppings AS
(
SELECT 
  t.topping_name,
  COUNT(pr.topping_id) AS total
FROM pizza_recipes pr
JOIN toppings t
  ON pr.topping_id = t.topping_id
JOIN order_items oi
  ON pr.pizza_id = oi.pizza_id
JOIN orders o
  ON oi.order_id = o.order_id
WHERE o.cancellation IS NULL
GROUP BY t.topping_name
ORDER BY topping_name ASC
),
adjustments AS
(SELECT
  topping_name,
  SUM(CASE
    WHEN amendment_type = 0 THEN -1
    WHEN amendment_type = 1 THEN 1
    ELSE 0
    END) AS total_adjustment
FROM toppings t
LEFT JOIN order_amendments oa
  ON t.topping_id = oa.topping_id
GROUP BY topping_name
ORDER BY topping_name ASC
)
SELECT
  tt.topping_name,
  tt.total AS total_toppings,
  a.total_adjustment AS total_amendments,
  tt.total + a.total_adjustment AS adjusted_total
FROM total_toppings tt
JOIN adjustments a
  ON tt.topping_name = a.topping_name
ORDER BY adjusted_total DESC;
```
