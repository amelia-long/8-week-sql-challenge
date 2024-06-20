<h1>Case Study 2 : Pizza Runner</h1>
<a href="https://8weeksqlchallenge.com/case-study-2/" target="_blank">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" width = "400">
</a>

## The schema
I started out with the [given schema](1_schema.sql) and [cleaned the data](2_data_cleaning.sql). However, once I started working on the case study questions I ran into problems which caused me to [redesign the schema](3_schema_v2.sql). 

For example, in the original pizza_recipes table, the topping_ids are given as a comma delimited list. This made querying the pizza ingredients difficult, so instead I created a topping_id column and stored the pizza recipes as one row per topping instead. 

The original table names were confusing too, so I renamed customer_orders to order_items and runner_orders to orders. I created a new deliveries table to store the delivery data that had been in the runner_orders table before. When it came to adding a rating (see question D3), I simply added a rating column to the deliveries table. The [EER diagram](pizza_runner_v2.png) shows the final revised schema. 

Of course, in the real world there would also be a customers and delivery addresses table, as well as name and contact details for the runners!

## Case Study Questions

### [A. Pizza Metrics](A_pizza_metrics.md)


<h3>B. Runner and Customer Experience</h3>
<ol>
<li>How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)</li>
<li>What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?</li>
<li>Is there any relationship between the number of pizzas and how long the order takes to prepare?</li>
<li>What was the average distance travelled for each customer?</li>
<li>What was the difference between the longest and shortest delivery times for all orders?</li>
<li>What was the average speed for each runner for each delivery and do you notice any trend for these values?</li>
<li>What is the successful delivery percentage for each runner?</li>
</ol>
<h3>C. Ingredient Optimisation</h3>
<ol>

<li>What are the standard ingredients for each pizza? </li>
<li>What was the most commonly added extra? </li>
<li>What was the most common exclusion? </li>
<li>Generate an order item for each record in the customers_orders table in the format of one of the following: </li>
<ul>
  <li>Meat Lovers </li>
  <li>Meat Lovers - Exclude Beef </li>
  <li>Meat Lovers - Extra Bacon </li>
  <li>Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers </li>
 </ul>
<li>Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" </li>
<li>What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? </li>
</ol>
<h3>D. Pricing and Ratings</h3>
<ol>
<li>If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?</li>
<li>What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra</li>
<li>The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.</li>
<li>Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?</li>
<ul>
<li>customer_id</li>
<li>order_id</li>
<li>runner_id</li>
<li>rating</li>
<li>order_time</li>
<li>pickup_time</li>
<li>Time between order and pickup</li>
<li>Delivery duration</li>
<li>Average speed</li>
<li>Total number of pizzas</li>
</ul>
<li>If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?</li>
</ol>
<h3>E. Bonus Question</h3>
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
