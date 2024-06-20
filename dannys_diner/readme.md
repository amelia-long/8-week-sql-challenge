# Case Study 1 : Danny's Diner

<a href="https://8weeksqlchallenge.com/case-study-1/" target="_blank">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" width = "400">
</a>

## Case Study Questions

### 1. What is the total amount each customer spent at the restaurant?

```sql
SELECT
	customer_id,
	SUM(price) AS total_spent
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
GROUP BY customer_id;
```

<img width="204" alt="Screenshot 2024-06-19 at 17 07 01" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/93a8484e-0057-46f3-83f7-b0f189f7af90">



### 2. How many days has each customer visited the restaurant?

```sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS num_days
FROM sales
GROUP BY customer_id;
```

<img width="204" alt="Screenshot 2024-06-19 at 17 08 00" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/3aaa3727-25a3-4250-b96d-f6f26bfd0d45">


### 3. What was the first item from the menu purchased by each customer?

```sql
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
```

<img width="217" alt="Screenshot 2024-06-19 at 17 08 39" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/341fb70f-a9a0-40db-a3ac-4d3468260c20">


### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT
	m.product_name,
  	COUNT(s.product_id) AS num_sales
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY num_sales DESC LIMIT 1;
```

<img width="217" alt="Screenshot 2024-06-19 at 17 09 09" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/e2ac4d6e-5120-48a1-9287-734d03854872">


### 5. Which item was the most popular for each customer?

```sql
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
```

<img width="217" alt="Screenshot 2024-06-19 at 17 09 37" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/b5a95266-b413-4eae-91dc-a4301c963ea0">


### 6. Which item was purchased first by the customer after they became a member?

```sql
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
```

<img width="234" alt="Screenshot 2024-06-19 at 17 10 09" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/b939f60c-7efc-4217-9e09-613db263ffe5">


### 7. Which item was purchased just before the customer became a member?

```sql
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
```

<img width="234" alt="Screenshot 2024-06-19 at 17 10 39" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/713d8040-c74a-4c89-9bdc-2ffa71b5d13f">


### 8. What is the total items and amount spent for each member before they became a member?

```sql
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
GROUP BY s.customer_id;
```

<img width="314" alt="Screenshot 2024-06-19 at 17 11 11" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/2657b4ad-8a36-41ec-b7a0-be27bd4696e6">


### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
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
```

<img width="184" alt="Screenshot 2024-06-19 at 17 11 44" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/5b98a9ff-b39e-4e05-bc3e-52ca44f4e05d">


### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
SELECT 
	s.customer_id,
	SUM(CASE 
		WHEN s.order_date >= mem.join_date AND s.order_date <= DATE_ADD(mem.join_date, INTERVAL 7 DAY) THEN m.price * 20
		WHEN m.product_name = "Sushi" AND s.order_date > DATE_ADD(mem.join_date, INTERVAL 7 DAY) THEN m.price * 20
		WHEN m.product_name != "Sushi" AND s.order_date > DATE_ADD(mem.join_date, INTERVAL 7 DAY) AND s.order_date < 2023-01-31 THEN m.price * 10
		ELSE null
	END) AS points
FROM sales AS s
JOIN menu AS m
	ON s.product_id = m.product_id
JOIN members AS mem
	ON s.customer_id = mem.customer_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

<img width="184" alt="Screenshot 2024-06-19 at 17 12 08" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/003d2211-7e66-4620-83c5-81d90dbf2081">
