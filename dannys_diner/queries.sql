-- DANNY'S DINER TASK

USE dannys_diner;

SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;

-- What is the total amount each customer spent at the restaurant?

SELECT
  customer_id,
  SUM(price) AS total_spent
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
GROUP BY customer_id;

-- How many days has each customer visited the restaurant?

SELECT 
  customer_id,
COUNT(DISTINCT order_date) AS num_days
FROM sales
GROUP BY customer_id
;

-- What was the first item from the menu purchased by each customer?

WITH first_item AS 
(
SELECT
	  s.customer_id,
    s.order_date,
    m.product_name,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS ranked
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
ORDER BY s.customer_id, ranked ASC, order_date ASC
)
SELECT
	  customer_id,
    GROUP_CONCAT(DISTINCT product_name) AS first_order_items
FROM first_item
WHERE ranked = 1
GROUP BY customer_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name,
COUNT(s.product_id) AS num_sales
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY num_sales DESC LIMIT 1;

-- Which item was the most popular for each customer?

WITH ranked_per_customer AS
(
SELECT
	  s.customer_id,
    m.product_name,
    COUNT(s.product_id) AS num_sales,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS ranked
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id ASC, num_sales DESC
)
SELECT 
	  customer_id, 
    GROUP_CONCAT(DISTINCT product_name) AS favorite_items 
FROM ranked_per_customer
WHERE ranked = 1 
GROUP BY customer_id;

-- what was the first item ordered after joining loyalty programme

WITH first_order_after_joining AS
(
SELECT 
	  s.customer_id,
    m.product_name,
    s.order_date,
    mem.join_date,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS ranked
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
JOIN members AS mem
	ON s.customer_id = mem.customer_id
WHERE s.order_date > mem.join_date
)
SELECT 
	  customer_id, 
    product_name AS first_item_after_joining
FROM first_order_after_joining
WHERE ranked = 1;

-- Which item was purchased just before the customer became a member?

WITH last_order_before_joining AS
(
SELECT 
	  s.customer_id,
    m.product_name,
    s.order_date,
    mem.join_date,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS ranked
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
JOIN members AS mem
	ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
)
SELECT 
	  customer_id, 
    GROUP_CONCAT(DISTINCT product_name) AS last_item_before_joining
FROM last_order_before_joining
WHERE ranked = 1
GROUP BY customer_id;

-- What is the total items and amount spent for each member before they became a member?

SELECT 
	  s.customer_id,
    SUM(m.price) AS total_spend,
    COUNT(s.product_id) AS total_items_ordered
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
JOIN members AS mem
	ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id
;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier
--  - how many points would each customer have?

SELECT
	s.customer_id,
  SUM(CASE WHEN m.product_name = "Sushi" THEN m.price * 20 ELSE m.price * 10 END) AS points
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
JOIN members AS mem
	ON s.customer_id = mem.customer_id
WHERE mem.join_date IS NOT NULL
GROUP BY s.customer_id;

-- In the first week after a customer joins the program 
-- (including their join date) they earn 2x points on all items, not just sushi 
-- - how many points do customer A and B have at the end of January?

SELECT 
	  s.customer_id,
    SUM(CASE 
    WHEN s.order_date >= mem.join_date AND s.order_date <= DATE_ADD(mem.join_date, INTERVAL 7 DAY) THEN m.price * 20
    WHEN m.product_name = "Sushi" AND s.order_date > DATE_ADD(mem.join_date, INTERVAL 7 DAY) THEN m.price * 20
    WHEN m.product_name != "Sushi" AND s.order_date > DATE_ADD(mem.join_date, INTERVAL 7 DAY) AND s.order_date < 2023-01-31 THEN m.price * 10
    ELSE null
    END)
    AS points
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
JOIN members AS mem
	ON s.customer_id = mem.customer_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- create following table output using the available data

SELECT
	  s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE WHEN mem.join_date IS NOT NULL AND s.order_date >= mem.join_date THEN "Y" ELSE "N" END AS `member`
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
LEFT JOIN members AS mem
	ON s.customer_id = mem.customer_id
ORDER BY s.customer_id, s.order_date, m.product_name;

-- RANKING TABLE

WITH rank_cte AS
(
SELECT
	  s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    mem.join_date,
    CASE WHEN order_date >= join_date THEN 'Y' ELSE 'N' END AS member
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
LEFT JOIN members AS mem
	ON s.customer_id = mem.customer_id
ORDER BY s.customer_id
)
SELECT 
	  customer_id,
    order_date,
    product_name,
    price,
	member,
    CASE WHEN member = 'y' AND order_date >= join_date THEN 
		RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date ASC)
    ELSE 
		NULL 
	END AS ranking
FROM rank_cte
ORDER BY customer_id, order_date, ranking;
