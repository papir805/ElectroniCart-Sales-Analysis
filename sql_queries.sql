-- AVERAGE DAYS BETWEEN ORDERS

-- Question 1: What is the typical amount of time between purchases for all customers, 
-- as well as that of loyalty vs non-loyalty customers?
-- Process:
-- Step 1: For each customer, calculate the number of days between each of their orders.
WITH date_differences AS (
  SELECT customer_id
         , DATE_DIFF(
             purchase_ts, 
             LAG(purchase_ts) OVER (
               PARTITION BY customer_id 
               ORDER BY purchase_ts
             ), DAY
           ) AS days_since_last_order 
  FROM core.orders 
    ),

-- Step 2: For each customer, find the average number of days between orders.
customer_avg_days_since_last_order AS (
  SELECT customer_id
         , AVG(days_since_last_order) AS avg_days_since_last_order
         , COUNT(days_since_last_order) AS num_purchases_beyond_first
  FROM date_differences
  WHERE days_since_last_order IS NOT NULL
  GROUP BY customer_id
),

-- Step 3: Calculate the average number of days between orders over orders placed by 
-- loyalty customers vs. orders placed by regular customers.
loyalty_avg_days_since_last_order AS (
  SELECT
    CASE
      WHEN loyalty_program = 1 THEN 'Loyalty Customer'
      WHEN loyalty_program = 0 THEN 'Regular Customer'
      ELSE 'Unknown' 
    END AS loyalty_status
    , ROUND(
        AVG(avg_days_since_last_order), 2
      ) AS avg_days_since_last_order
    , COUNT(*) AS frequency 
  FROM customer_avg_days_since_last_order
    LEFT JOIN core.customers
      ON customers.id = customer_avg_days_since_last_order.customer_id  
  GROUP BY loyalty_program
),

-- Step 4: Calculate the average number of days between orders over all orders placed 
-- by all customers.
overall_avg_days_since_last_order AS (
  SELECT 'Overall' AS type
         , ROUND(
             AVG(avg_days_since_last_order), 2
           ) AS avg_days_since_last_order
  FROM customer_avg_days_since_last_order
)

-- Step 5: Union the overall average with the loyalty program averages.
SELECT type
       , avg_days_since_last_order
FROM overall_avg_days_since_last_order
UNION ALL
(SELECT loyalty_status
        , avg_days_since_last_order
FROM loyalty_avg_days_since_last_order)
ORDER BY avg_days_since_last_order DESC;


--LOYALTY QUERIES

-- Question 1: How do shipping times compare for loyalty vs. non-loyalty customers?
-- Process: Calculate the shipping time for each order (delivery_ts - ship_ts) and 
-- average it grouping by loyalty_program
SELECT
  CASE 
    WHEN customers.loyalty_program = 1 THEN 'Loyalty' 
    WHEN customers.loyalty_program = 0 THEN 'Non-Loyalty'
    ELSE 'Unknown'
  END AS loyalty_status
  , ROUND(
      AVG(
        DATE_DIFF(order_status.delivery_ts, order_status.ship_ts, DAY)
        ), 3
    ) AS avg_days_to_deliver
FROM core.customers
  LEFT JOIN core.orders
    ON customers.id = orders.customer_id
  LEFT JOIN core.order_status
    ON orders.id = order_status.order_id
GROUP BY customers.loyalty_program
ORDER BY avg_days_to_deliver DESC;

-- Question 2: Which marketing channels attract the most loyalty members?  What about for 
-- non-loyalty members?  
-- Process: Calculate the percentage of users who signed up through a given marketing channel 
-- as defined by:
-- signup_pct = 100 * (x_signups_for_y_marketing_channel_in_z_partition) / 
--                                                            (total_users_in_z_partition)
-- partitioned by one's loyalty program status.  
-- Note: some customers have NULL values for the marketing channel field and their marketing
-- channel will be reassigned to 'Unknown'.
WITH loyalty_marketing_channel_pcts AS (
  SELECT 
    CASE 
         WHEN loyalty_program = 1 THEN 'Loyalty' 
         WHEN loyalty_program = 0 THEN 'Non-Loyalty' 
         ELSE 'Unknown' 
    END AS loyalty_status
    , COALESCE(marketing_channel, 'unknown') AS marketing_channel
    , ROUND(
        100 * COUNT(marketing_channel) / SUM(
          COUNT(marketing_channel)
        ) OVER (PARTITION BY loyalty_program)
        , 2
      ) AS signup_pct 
  FROM core.customers 
  GROUP BY loyalty_program, marketing_channel
)

SELECT * 
FROM loyalty_marketing_channel_pcts
ORDER BY loyalty_status, signup_pct DESC;

-- Question 3: Which purchase platforms are most frequently used by loyalty members? 
--- Process: Calculate the percentage of orders from a given purchase_platform as defined by:
-- pct_used = 100 * (x_orders_for_y_purchase_platform_in_z_partition) / 
--                                                       (total_users_in_z_partition)
-- partitioned by one's loyalty program status.  
-- Note: Some orders have customer_ids that do not match with any in the customers table, 
-- leading to 27,267 orders where the loyalty_status of the customer making the purchase 
-- is unknown.  These orders can't help understand which purchase platforms are most used 
-- by loyalty members and will be excluded in this part of the analysis.
SELECT 
  CASE
       WHEN loyalty_program = 1 THEN 'Loyalty' 
       WHEN loyalty_program = 0 THEN 'Non-Loyalty'
       ELSE 'Unknown'
   END AS loyalty_status
   , orders.purchase_platform
   , ROUND(
       100 * COUNT(orders.purchase_platform) 
               / SUM(COUNT(orders.purchase_platform)) OVER (PARTITION BY loyalty_program)
          , 2
          ) AS pct_used
FROM core.orders
  LEFT JOIN core.customers
    ON orders.customer_id = customers.id
WHERE loyalty_program IS NOT NULL
GROUP BY customers.loyalty_program, orders.purchase_platform
ORDER BY loyalty_status, pct_used DESC;

SELECT *
FROM core.orders
LEFT JOIN core.customers
  ON orders.customer_id = customers.id
WHERE loyalty_program IS NULL

-- PRODUCT SALES VOLUME PCT CHANGE

-- Distinct Uncleaned Product Names:
SELECT DISTINCT product_name
FROM core.orders;

-- Question 1: Sales consistently drop from September to October.  Are certain 
-- products more succeptible to dips in sales during this time?
-- Process: 
-- Step 1 - Cleand and standardize product names
-- Use REPLACE to clean: 27in" 4k gaming monitor -> 27in 4k gaming monitor
-- Use LOWER to clean: 27in 4K gaming monitor -> 27in 4k gaming monitor
-- Use INITCAP to capitalize the first letter of every word
WITH cleaned_orders AS (
  SELECT INITCAP(
           REPLACE(
             LOWER(product_name)
          , '"', '')
         ) AS cleaned_product_name
         , *
  FROM core.orders
),

-- Step 2 - Calculate monthly sales volume for each product
monthly_sales AS (
  SELECT cleaned_product_name
         , DATE_TRUNC(purchase_ts, MONTH) AS date_of_purchase
         , COUNT(DISTINCT id) order_count
  FROM cleaned_orders
  GROUP BY cleaned_product_name, DATE_TRUNC(purchase_ts, MONTH)
  ),

-- Step 3 - Calculate monthly percent change in sales volume for each product
order_count_pct_changes AS (
  SELECT cleaned_product_name
         , date_of_purchase
         , 100 * (
             order_count - LAG(order_count) OVER (
                               PARTITION BY cleaned_product_name 
                               ORDER BY date_of_purchase
               )
           ) / (
             LAG(order_count) OVER (
                   PARTITION BY cleaned_product_name
                   ORDER BY date_of_purchase
             )
          ) AS order_count_pct_change
  FROM monthly_sales
  ORDER BY cleaned_product_name, date_of_purchase
  )

-- Step 4 - Filter to show only percent changes from Sept to Oct and find the average 
-- pct change in sales for each product 
SELECT cleaned_product_name
       , ROUND(
           AVG(order_count_pct_change), 2
         ) AS avg_sept_to_oct_pct_change
FROM order_count_pct_changes
WHERE EXTRACT(MONTH FROM date_of_purchase) IN (10)
GROUP BY cleaned_product_name
ORDER BY avg_sept_to_oct_pct_change;

-- Question 2: The Bose Soundsport Headphones only had ~$3,000 in sales.  How many 
-- units of this item were sold? 
SELECT product_name
       , COUNT(DISTINCT id) AS num_sold
FROM core.orders
WHERE product_name LIKE '%bose soundsport%'
GROUP BY product_name;

