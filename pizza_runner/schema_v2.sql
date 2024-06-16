-- PIZZA RUNNER V2 - AMENDED SCHEMA

CREATE DATABASE pizza_runner_v2;
USE pizza_runner_v2;

CREATE TABLE orders
(
order_id INT AUTO_INCREMENT PRIMARY KEY,
customer_id INT,
order_time TIMESTAMP,
cancellation VARCHAR(50),
order_total INT
);

CREATE TABLE order_items
(
order_item_id INT AUTO_INCREMENT PRIMARY KEY,
order_id INT,
pizza_id INT
);

CREATE TABLE order_amendments
(
amendment_id INT AUTO_INCREMENT PRIMARY KEY,
order_item_id INT,
amendment_type BOOLEAN,
topping_id INT
);

CREATE TABLE deliveries
(
delivery_id INT AUTO_INCREMENT PRIMARY KEY,
order_id INT,
runner_id INT,
pickup_time TIMESTAMP,
delivery_time TIMESTAMP,
distance_km INT
);

CREATE TABLE runners
(
runner_id INT AUTO_INCREMENT PRIMARY KEY,
registration_date DATE
);

CREATE TABLE pizzas
(
pizza_id INT AUTO_INCREMENT PRIMARY KEY,
pizza_name VARCHAR(100),
pizza_price INT
);

CREATE TABLE toppings
(
topping_id INT AUTO_INCREMENT PRIMARY KEY,
topping_name VARCHAR(50),
topping_price INT
);

CREATE TABLE pizza_recipes
(
pizza_id INT,
topping_id INT
);

CREATE TABLE ratings
(
rating_id INT AUTO_INCREMENT PRIMARY KEY,
runner_id INT,
order_id INT,
rating INT
);

-- additions (if in the real world)

-- CREATE TABLE customers
-- (
-- customer_id INT,
-- first_name VARCHAR(50),
-- last_name VARCHAR(50),
-- phone INT,
-- email VARCHAR(100)
-- );

-- CREATE TABLE delivery_address
-- (
-- address_id INT,
-- customer_id INT,
-- address VARCHAR(100),
-- city VARCHAR(50),
-- state VARCHAR(3),
-- zip VARCHAR(10)
-- );

-- INSERT DATA

-- ORDERS data < pizza_runner.runner_orders AND pizza_runner.customer_orders

INSERT INTO orders (order_id, customer_id, order_time, cancellation)
SELECT DISTINCT
	r.order_id, 
    co.customer_id, 
    co.order_time, 
    r.cancellation
FROM 
	pizza_runner.runner_orders AS r
    LEFT JOIN pizza_runner.customer_orders AS co
    ON r.order_id = co.order_id;


-- DELIVERIES data < pizza_runner.runner_orders

INSERT INTO deliveries (order_id, runner_id, pickup_time, delivery_time, distance_km)
SELECT
	r.order_id,
    r.runner_id,
    r.pickup_time,
    DATE_ADD(r.pickup_time, INTERVAL r.duration MINUTE) AS delivery_time,
    r.distance AS distance_km
FROM pizza_runner.runner_orders AS r
JOIN orders AS o
ON r.order_id = o.order_id
WHERE o.cancellation IS NULL;

-- ORDER ITEMS < pizza_runner.customer_orders

INSERT INTO order_items (order_id, pizza_id)
SELECT
	co.order_id,
    co.pizza_id
FROM pizza_runner.customer_orders AS co;


-- PIZZAS < pizza_runner.pizza_names

INSERT INTO pizzas (pizza_id, pizza_name)
SELECT
	pizza_id,
    pizza_name
FROM pizza_runner.pizza_names;


-- PIZZA RECIPES < pizza_runner.pizza_recipes
	-- toppings entered as rows not comma delimiited list

INSERT INTO pizza_recipes (pizza_id, topping_id)
SELECT 
	pizza_id,
    topping_id
FROM pizza_runner.pizza_recipes;

-- TOPPINGS < pizza_runner.pizza_toppings

INSERT INTO toppings (topping_id, topping_name)
SELECT
	topping_id,
    topping_name
FROM pizza_runner.pizza_toppings;

-- RUNNERS < pizza_runner.runners

INSERT INTO runners (runner_id, registration_date)
SELECT
	runner_id,
    registration_date
FROM pizza_runner.runners;

-- ORDER_AMENDMENTS (manual entry)

SELECT * FROM pizza_runner.runner_orders;
SELECT * FROM pizza_runner.customer_orders;
SELECT * FROM order_items;
SELECT * FROM toppings;

INSERT INTO order_amendments (order_item_id,amendment_type,topping_id)
VALUES
(5,0,4),
(6,0,4),
(7,0,4),
(8,1,1),
(10,1,1),
(12,0,4),
(12,1,1),
(12,1,5),
(14,0,2),
(14,0,6),
(14,1,1),
(14,1,4);

-- CHECK TABLES

SELECT * FROM order_amendments;
SELECT * FROM deliveries;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM pizza_recipes;
SELECT * FROM pizzas;
SELECT * FROM runners;
SELECT * FROM toppings;

-- SET FOREIGN KEYS

ALTER TABLE order_items
ADD CONSTRAINT FK_order_id
FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT FK_pizza_id
FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id);

ALTER TABLE order_amendments
ADD CONSTRAINT FK_order_item_id
FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id);

ALTER TABLE order_amendments
ADD CONSTRAINT FK_topping_id
FOREIGN KEY (topping_id) REFERENCES toppings(topping_id);

ALTER TABLE deliveries
ADD CONSTRAINT FK_del_order_id
FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE deliveries
ADD CONSTRAINT FK_runner_id
FOREIGN KEY (runner_id) REFERENCES runners(runner_id);

ALTER TABLE pizza_recipes
ADD CONSTRAINT FK_recipes_pizza_id
FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id);

ALTER TABLE pizza_recipes
ADD CONSTRAINT FK_recipes_topping_id
FOREIGN KEY (topping_id) REFERENCES toppings(topping_id);
