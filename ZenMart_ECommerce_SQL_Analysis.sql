-- Data type of all columns in the "customers" table.
select  column_name,
data_type
FROM `ZenMartData.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name='customersT';

-- Get the time range between which the orders were placed.

select MIN(order_purchase_timestamp) first_date,MAX(order_purchase_timestamp) end_date
FROM `ZenMartData.ordersT`;

-- Count the Cities & States of customers who ordered during the given period.

select COUNT(DISTINCT custT.customer_city) uniqueCityCount,COUNT(DISTINCT custT.customer_state) uniqueCustState
FROM `ZenMartData.customersT` custT 
JOIN `ZenMartData.ordersT` orderT
ON custT.customer_id= orderT.customer_id;

-- Is there a growing trend in the no. of orders placed over the past years?
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) yearP,count(order_id) total_orders
from `ZenMartData.ordersT`
WHERE order_status  NOT IN('canceled','unavailable')
GROUP BY  EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY yearP;


-- Can we see some kind of monthly seasonality in terms of the no. of orders being placed !delivered?
select EXTRACT(MONTH FROM order_purchase_timestamp) order_month,count(order_id) orderCount
FROM `ZenMartData.ordersT`
WHERE order_status="delivered"
GROUP BY EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY orderCount DESC;

-- During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
WITH day_time as (SELECT CASE
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Mornings'
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 19 AND 23 THEN 'Night'
END AS Day_name
FROM `ZenMartData.ordersT`)

select day_name,count(day_name) count_orders
FROM day_time
GROUP BY day_name 
ORDER BY count_orders DESC;

-- Get the month on month no. of orders placed in each state.

SELECT custT.customer_state,EXTRACT(YEAR FROM orderT.order_purchase_timestamp) order_year,
EXTRACT(MONTH FROM orderT.order_purchase_timestamp) order_month,
count(DISTINCT order_id) order_count
FROM `ZenMartData.ordersT`  AS orderT
JOIN `ZenMartData.customersT` AS custT
ON orderT.customer_id=custT.customer_id
WHERE orderT.order_status  NOT IN('canceled','unavailable')
GROUP BY EXTRACT(MONTH FROM orderT.order_purchase_timestamp),EXTRACT(YEAR FROM orderT.order_purchase_timestamp),custT.customer_state
ORDER BY custT.customer_state,order_year,order_month;

--How are the customers distributed across all the states?
select customer_state,count( DISTINCT customer_unique_id) total_customer
from `ZenMartData.customersT`
GROUP BY customer_state
ORDER BY total_customer DESC;

-- Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).

SELECT ROUND(((LEAD(tbl.total_order_value)OVER(order by yearInfo) - tbl.total_order_value)/tbl.total_order_value*100),2) total_percenage_increses
FROM (
WITH orderValue as (
select ordersT.order_id, paymentT.payment_value,EXTRACT(YEAR FROM order_purchase_timestamp) yearInfo,EXTRACT(MONTH FROM order_purchase_timestamp) monthInfo
FROM `ZenMartData.paymentsT` paymentT
JOIN `ZenMartData.ordersT` ordersT 
ON paymentT.order_id=ordersT.order_Id
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) in (2017,2018)
AND EXTRACT(MONTH FROM order_purchase_timestamp) in (1,2,3,4,5,6,7,8)
ORDER BY yearInfo,monthInfo )

SELECT yearInfo,sum(payment_value) total_order_value
FROM orderValue
GROUP BY yearInfo 
) as tbl
ORDER BY Yearinfo 
LIMIT 1;

-- Calculate the Total & Average value of order price for each state.

SELECT custT.customer_state,ROUND(SUM(order_itemT.price),2) total_value, ROUND(AVG(order_itemT.price),2) total_averageValue
FROM `ZenMartData.customersT` custT
JOIN `ZenMartData.ordersT` orderT
ON custT.customer_id=orderT.customer_id 
JOIN `ZenMartData.order_items` order_itemT
ON order_itemT.order_id=orderT.order_id
GROUP BY custT.customer_state 
ORDER BY total_value DESC;

-- -Calculate the Total & Average value of order freight for each state.
SELECT custT.customer_state,ROUND(SUM(order_itemT.freight_value),2) total_frieght_value, ROUND(AVG(order_itemT.freight_value),2) total_avg_frieght_Value
FROM `ZenMartData.customersT` custT
JOIN `ZenMartData.ordersT` orderT
ON custT.customer_id=orderT.customer_id 
JOIN `ZenMartData.order_items` order_itemT
ON order_itemT.order_id=orderT.order_id
GROUP BY custT.customer_state 
ORDER BY total_frieght_value DESC;

-- Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.
-- Also, calculate the difference (in days) between the estimated & actual delivery date of an order.
-- Do this in a single query........here - minus show early delivery and + show late delivery......
SELECT order_id ,TIMESTAMP_DIFF(order_delivered_customer_date,order_purchase_timestamp,DAY) time_to_delivery,
TIMESTAMP_DIFF(order_delivered_customer_date,order_estimated_delivery_date,DAY) diff_estimated_delivery 
FROM `ZenMartData.ordersT`;

--Find out the top 5 states with the highest & lowest average freight value.
WITH highest_frieght_value AS (
select custT.customer_state,ROUND(AVG(orderItemT.freight_value),2) avg_freight_value,'Highest' as frieght_value
FROM `ZenMartData.customersT` custT 
JOIN `ZenMartData.ordersT` orderT 
ON custT.customer_id=orderT.customer_id 
JOIN `ZenMartData.order_items` orderItemT 
ON orderItemT.order_id=orderT.order_id
GROUP BY custT.customer_state 
ORDER BY avg_freight_value DESC 
LIMIT 5 ),
lowest_freight_value AS (
select custT.customer_state,ROUND(AVG(orderItemT.freight_value),2) avg_freight_value,'Lowest'as frieght_value
FROM `ZenMartData.customersT` custT 
JOIN `ZenMartData.ordersT` orderT 
ON custT.customer_id=orderT.customer_id 
JOIN `ZenMartData.order_items` orderItemT 
ON orderItemT.order_id=orderT.order_id
GROUP BY custT.customer_state 
ORDER BY avg_freight_value
LIMIT 5) 
SELECT *
FROM highest_frieght_value 
UNION ALL 
SELECT *
FROM lowest_freight_value;

-- Find out the top 5 states with the highest & lowest average delivery time.
WITH highest_avg_time AS (
  select custT.customer_state,ROUND(AVG(TIMESTAMP_DIFF(ordersT.order_delivered_customer_date,order_purchase_timestamp,DAY))) avrg_delivery_time,'Highest' delivery_time
  FROM `ZenMartData.ordersT` ordersT
  JOIN `ZenMartData.customersT` custT 
  ON ordersT.customer_id=custT.customer_id
  WHERE ordersT.order_delivered_customer_date IS NOT NULL
  GROUP BY custT.customer_state 
  ORDER BY avrg_delivery_time DESC 
  LIMIT 5),
lowest_avg_time AS(
  select custT.customer_state,ROUND(AVG(TIMESTAMP_DIFF(ordersT.order_delivered_customer_date,order_purchase_timestamp,DAY))) avrg_delivery_time,'Lowest' delivery_time
  FROM `ZenMartData.ordersT` ordersT
  JOIN `ZenMartData.customersT` custT 
  ON ordersT.customer_id=custT.customer_id 
  WHERE ordersT.order_delivered_customer_date IS NOT NULL
  GROUP BY custT.customer_state 
  ORDER BY avrg_delivery_time ASC 
  LIMIT 5) 

  SELECT *
  FROM highest_avg_time 
  UNION ALL 
  SELECT *
  FROM lowest_avg_time;

  -- Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery. here - minus show fast delivery early sign

  SELECT custT.customer_state,ROUND(AVG(TIMESTAMP_DIFF(orderT.order_delivered_customer_date,orderT.order_estimated_delivery_date,DAY))) time_difference
  FROM `ZenMartData.customersT` custT 
  JOIN  `ZenMartData.ordersT` orderT 
  ON custT.customer_id=orderT.customer_id 
  WHERE orderT.order_delivered_customer_date IS NOT NULL
  GROUP BY custT.customer_state 
  ORDER BY time_difference 
  LIMIT 5;

-- Find the month on month no. of orders placed using different payment types.
SELECT payment_type,orderYear,orderMonth,count(*) orders_counts
FROM (
select payT.payment_type,EXTRACT( YEAR FROM orderT.order_purchase_timestamp) orderYear,EXTRACT( MONTH FROM orderT.order_purchase_timestamp) orderMonth
FROM `ZenMartData.paymentsT` payT 
JOIN `ZenMartData.ordersT` orderT 
ON payT.order_id=orderT.order_id ) tbl
GROUP BY payment_type,orderYear,orderMonth 
ORDER BY orderYear,orderMonth;

-- Find the no. of orders placed on the basis of the payment installments that have been paid.

select payT.payment_installments,count(DISTINCT orderT.order_id) orders_counts
FROM `ZenMartData.paymentsT` payT 
JOIN `ZenMartData.ordersT` orderT 
ON payT.order_id=orderT.order_id
GROUP BY payT.payment_installments
