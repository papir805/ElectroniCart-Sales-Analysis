-- Distinct Uncleaned Product Names:
SELECT DISTINCT product_name
FROM core.orders;

-- Results:
-- product_name
-- Apple Airpods Headphones
-- ThinkPad Laptop
-- Samsung Webcam
-- 27in 4K gaming monitor
-- Macbook Air Laptop
-- Samsung Charging Cable Pack
-- Apple iPhone
-- "27in"""" 4k gaming monitor"
-- bose soundsport headphones

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

-- Results:
-- cleaned_product_name	      | avg_sept_to_oct_pct_change
-- thinkpad laptop	           | -47.24
-- samsung webcam	           | -33.43
-- apple airpods headphones	 | -31.17
-- 27in 4k gaming monitor	 | -31.03
-- samsung charging cable pack | -28.47
-- apple iphone	           | -14.56
-- macbook air laptop	      | -14.3
-- bose soundsport headphones	 | 0.0

-- Question 2: The Bose Soundsport Headphones only had ~$3,000 in sales.  How many 
-- units of this item were sold? 
SELECT product_name
       , COUNT(DISTINCT id) AS num_sold
FROM core.orders
WHERE product_name LIKE '%bose soundsport%'
GROUP BY product_name;

-- product_name 	          | num_sold
-- bose soundsport headphones	| 27