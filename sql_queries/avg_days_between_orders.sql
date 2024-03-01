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

-- Results:
-- type	            | avg_days_since_last_order
-- Regular Customer |	199.26
-- Loyalty Customer	| 133.61
-- Overall	        | 53.71
-- Unknown	        | 1.35