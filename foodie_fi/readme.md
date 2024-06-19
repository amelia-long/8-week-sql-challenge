# Case Study 3: Foodie-Fi

<a href="https://8weeksqlchallenge.com/case-study-3/">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/3.png" width="400">
</a>

## A. Customer Journey
#### Customer 1
Started free trial 1 Aug 2020, upgraded to basic monthly plan on 8 Aug at the end of their free trial period.
#### Customer 2
Started free trial 20 Sep 2020, upgraded to pro annual plan on 27 Sep 2020 at end of trial period.
#### Customer 11
Started free trial on 19 Nov 2020, cancelled on 26 Nov at end of trial period.
#### Customer 13
Started free trial on 15 Dec 2020,  upgraded to basic monthly on 22 Dec, then upgraded to pro monthly on 29 Mar 2021.
#### Customer 15
Started free trial on 17 Mar 2020, upgraded to pro monthly on 24 Mar (automatic), cancelled on 29 Mar.
#### Customer 16
Started free trial on 31 May 2020, upgraded to basic monthly on 7 Jun, upgraded to pro annual on 21 Oct.
#### Customer 18
Started free trial on 6 Jul 2020, upgraded to pro monthly on 13 Jul (end of trial period, automatic).
#### Customer 19
Started free trial on 22 Jun, upgraded to pro monthly on 29 Jun (automatic at end of trial period), upgraded to pro annual on 29 Aug.

## B. Data Analysis Questions

Lots of practice with ctes and window functions in this case study.

### 1. How many customers has Foodie-Fi ever had?

```
SELECT
COUNT(DISTINCT customer_id) AS total_customer_count
FROM subscriptions;
```

Output: Foodie-Fi has a total customer count of exactly 1000.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```
SELECT
  DATE_FORMAT(start_date, "%Y") AS year,
  DATE_FORMAT(start_date,"%m") AS month,
  COUNT(customer_id) AS total_trial_starts
FROM subscriptions
WHERE plan_id = 0
GROUP BY DATE_FORMAT(start_date, "%Y"), DATE_FORMAT(start_date,"%m")
ORDER BY DATE_FORMAT(start_date,"%m") ASC;
```

Output: Peak month was Mar 2020 with 94 trial plan starts. Feb 2020 had the lowest number of trial plan starts at 68.

<img width="240" alt="Screenshot 2024-06-19 at 13 46 01" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/94f7264a-5634-457e-93db-1b17efdeb58e">


### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

```
SELECT
  p.plan_name,
  COUNT(start_date) AS event_count
FROM subscriptions s
JOIN plans p
  ON s.plan_id = p.plan_id
WHERE YEAR(s.start_date) > 2020
GROUP BY p.plan_name;
```

Output: 71 churns, 60 pro monthly subscriptions, 63 pro annual subscriptions and 8 basic monthly subscriptions/

<img width="208" alt="Screenshot 2024-06-19 at 13 47 14" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/506915f3-6a7c-4fa1-8e52-446beb763c0f">



### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```
WITH cust_count AS
(
SELECT
  COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions
 ),
churn_count AS
 (
SELECT
  COUNT(DISTINCT customer_id) AS churn_count
FROM subscriptions
WHERE plan_id = 4
 )
SELECT
  customer_count,
  ROUND((churn_count/customer_count) * 100,1) AS churn_percentage
FROM cust_count, churn_count;
```

Output: 30.7% churn rate

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

Initial solution:

```
WITH trial_end AS
(
SELECT
  customer_id,
  DATE_ADD(start_date, INTERVAL 7 DAY) AS end_of_trial
FROM subscriptions
WHERE plan_id = 0
)
SELECT
  COUNT(s.customer_id) AS total_churners,
  ROUND(COUNT(s.customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS churn_percentage
FROM subscriptions s
JOIN trial_end te
	ON s.customer_id = te.customer_id
WHERE plan_id = 4
AND s.start_date = te.end_of_trial;

```

I forgot about LAG(), which is a better way to do this:

```

WITH lag_cte AS
(
SELECT
  customer_id,
  LAG(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date ASC) AS prev_plan,
  plan_id
FROM subscriptions
)
SELECT 
  COUNT(customer_id) AS churner_total,
  ROUND((COUNT(customer_id)/1000) * 100) AS percentage_churners
FROM lag_cte
WHERE prev_plan = 0 AND plan_id = 4;
;
```

Output: 9% of customers churned straight after their free trial.

### 6. What is the number and percentage of customer plans after their initial free trial?

Without window function:

```
WITH trial_end AS
(
SELECT
  customer_id,
  DATE_ADD(start_date, INTERVAL 7 DAY) AS end_of_trial
FROM subscriptions
WHERE plan_id = 0
)
SELECT
  p.plan_name,
  ROUND(COUNT(s.customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS `% plan choice after trial`,
  CASE WHEN p.plan_name = "pro monthly" THEN "default plan after trial" ELSE "" END AS notes
FROM subscriptions s
JOIN trial_end te
  ON s.customer_id = te.customer_id
JOIN plans p
	ON s.plan_id = p.plan_id
WHERE s.plan_id != 0
AND s.start_date = te.end_of_trial
GROUP BY p.plan_name;
```

And with LEAD() window function:

```

WITH lead_cte AS
(
SELECT
  customer_id,
  plan_id,
  LEAD(plan_id,1) OVER(PARTITION BY customer_id ORDER BY start_date ASC) AS next_plan
FROM subscriptions
)
SELECT
	p.plan_name,
  ROUND(COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100,1) AS `% subscriptions after trial`,
  CASE WHEN p.plan_name = "pro monthly" THEN "NB: default plan after trial" ELSE "" END AS notes
FROM lead_cte l
JOIN plans p
	ON p.plan_id = l.next_plan
WHERE l.next_plan IS NOT NULL and l.plan_id = 0
GROUP BY p.plan_name
ORDER BY ROUND(COUNT(customer_id)/1000 * 100,1) DESC;
```

Output: 54.6% of customers chose the basic monthly plan, 32.5% chose the pro monthly plan (but this is the default plan after the free trial, so this may include customers who forgot to either choose a plan or cancel), 3.7% of customers went straight for the pro annual plan, and 9.2% of customers cancelled.

<img width="408" alt="Screenshot 2024-06-19 at 14 39 32" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/d042fa00-6f4a-4dc7-bccd-44853c6e30b6">



### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

Here I use RANK() window function to get only those subscriptions which are active at 2020-12-31.

```
WITH max_start AS
(    
SELECT 
  customer_id,
  plan_id,
  start_date,
  RANK() OVER(PARTITION BY customer_id ORDER BY start_date DESC) AS date_rank
FROM subscriptions
WHERE start_date <= '2020-12-31'
)
SELECT
  p.plan_name,
  COUNT(m.customer_id) AS customer_count,
  ROUND(COUNT(m.customer_id)/(SELECT count(DISTINCT customer_id) FROM max_start) * 100,1) AS `% customers`
FROM max_start m
JOIN plans p
	ON m.plan_id = p.plan_id
WHERE m.date_rank = 1
GROUP BY p.plan_name WITH ROLLUP;
```

Output: 32.6% pro monthly, 22.4% basic monthly, 19.5% pro annual, 1.9% on free trial, and 23.6% churns.

<img width="281" alt="Screenshot 2024-06-19 at 14 40 59" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/676aaf66-6059-413c-89c5-86c6af8ddf2f">


### 8. How many customers have upgraded to an annual plan in 2020?

The Pro Annual plan is plan_id 3.

```
SELECT
  COUNT(customer_id) AS pro_annual_upgrades
FROM subscriptions
WHERE plan_id = 3
AND YEAR(start_date) = 2020;

```

Output: 195 customers upgraded to an annual plan in 2020.

### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

Here I could have used a window function to get the minimum start date, but MIN() seemed more straightforward.

```
WITH join_date AS
(
SELECT 
  customer_id,
  MIN(start_date) AS join_date
FROM subscriptions
GROUP BY customer_id
)
SELECT 
  ROUND(AVG(DATEDIFF(s.start_date, j.join_date))) AS average_days_to_annual_upgrade
FROM subscriptions s
JOIN join_date j
  ON s.customer_id = j.customer_id
WHERE s.plan_id = 3;

```

Output: average 105 days

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

Some serious googling was needed to work out how to get the 30 day periods!

```
-- get start dates of trial plans
WITH trial_plan AS (
SELECT
    customer_id,
    start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0
),
-- get start dates of annual plans
annual_plan AS (
SELECT
  customer_id,
  start_date as annual_date
FROM subscriptions
WHERE plan_id = 3
)
SELECT 
-- 30 day periods
  CONCAT(FLOOR(DATEDIFF(ap.annual_date,tp.trial_date)/30) * 30," - ",FLOOR(DATEDIFF(ap.annual_date,tp.trial_date)/30) * 30 + 30) AS period,
  COUNT(tp.customer_id) AS number_of_upgrades,
  ROUND(AVG(DATEDIFF(ap.annual_date,tp.trial_date))) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap ON tp.customer_id = ap.customer_id
WHERE ap.annual_date IS NOT NULL
GROUP BY CONCAT(FLOOR(DATEDIFF(ap.annual_date,tp.trial_date)/30) * 30," - ",FLOOR(DATEDIFF(ap.annual_date,tp.trial_date)/30) * 30 + 30)
ORDER BY ROUND(AVG(DATEDIFF(ap.annual_date,tp.trial_date)));
```

Output:

<img width="400" alt="Screenshot 2024-06-19 at 14 41 52" src="https://github.com/amelia-long/8-week-sql-challenge/assets/158860669/6abede2e-5696-4986-bfe0-a71de13b2d9d">


### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

My approach here gets a count of customers who have downgraded, however it would probably be better to use a window function to capture this data, because it is possible that a customer could have subscribed to pro monthly, then upgraded to pro annual, then downgraded to basic monthly (for example) and would be counted by this query. That's not necessarily what the company wants to know. A window function would capture direct downgrades from pro monthly to basic monthly and disregard indirect downgrades.

```
WITH plan_1 AS
(
SELECT customer_id, start_date FROM subscriptions WHERE plan_id = 1 AND YEAR(start_date) = 2020
),
plan_2 AS
(
SELECT customer_id, start_date FROM subscriptions WHERE plan_id = 2 AND YEAR(start_date) = 2020
)
SELECT 
  COUNT(plan_1.customer_id) AS downgraders
FROM plan_1
JOIN plan_2 
	ON plan_1.customer_id = plan_2.customer_id
WHERE plan_1.start_date >= plan_2.start_date;
```

Output: zero (which made me think I'd got it wrong, but after checking it's the correct answer).

## C. Challenge Payment Question

This requires a recursive CTE to generate payment data: working out how to do this is still a work in progress ...

## D. Outside The Box Questions


The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!


1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
