-- Standardize product names:
-- Use replace to clean: 27in" 4k gaming monitor -> 27in 4k gaming monitor
-- Use LOWER to clean: 27in 4K gaming monitor -> 27in 4k gaming monitor
WITH cleaned_orders AS (
  SELECT REPLACE(LOWER(product_name), '"', '') AS cleaned_product_name
       , *
    FROM core.orders
),

-- Calculate monthly sales volume for each product
monthly_sales AS (
    SELECT cleaned_product_name
         , DATE_TRUNC(purchase_ts, MONTH) AS date_of_purchase
         , COUNT(DISTINCT id) order_count
      FROM cleaned_orders
  GROUP BY cleaned_product_name
         , DATE_TRUNC(purchase_ts, MONTH)
),

-- Calculate monthly percent change in sales volume for each product
order_count_pct_changes AS (
    SELECT cleaned_product_name
      , date_of_purchase
      , 100 * (order_count - LAG(order_count) OVER (PARTITION BY cleaned_product_name ORDER BY date_of_purchase)) 
         / (LAG(order_count) OVER (PARTITION BY cleaned_product_name ORDER BY date_of_purchase)) 
         AS order_count_pct_change
  FROM monthly_sales
  ORDER BY 1, 2
)

-- Investigate why sales consistently dip from Sept -> Oct
SELECT cleaned_product_name
     , date_of_purchase
     , ROUND(order_count_pct_change, 2) AS order_count_pct_change
FROM order_count_pct_changes
WHERE EXTRACT(MONTH FROM date_of_purchase) IN (10);