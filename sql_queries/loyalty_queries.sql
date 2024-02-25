-- Question 1: How do shipping times compare  for loyalty vs. non-loyalty customers?
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
FROM 
  core.customers
  LEFT JOIN core.orders
    ON customers.id = orders.customer_id
  LEFT JOIN core.order_status
    ON orders.id = order_status.order_id
GROUP BY
  customers.loyalty_program
ORDER BY
  avg_days_to_deliver DESC;
-- Results:
-- loyalty_status	 | avg_days_to_deliver
-- Loyalty	       | 5.504
-- Non-Loyalty	   | 5.502

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
  FROM 
    core.customers 
  GROUP BY 
    loyalty_program,
    marketing_channel
)

SELECT 
  * 
FROM 
  loyalty_marketing_channel_pcts
ORDER BY 
  loyalty_status,
  signup_pct DESC;

-- Results:
-- loyalty_status	| marketing_channel |	signup_pct
-- Loyalty	      | direct	          | 72.76
-- Loyalty	      | email	            | 24.53
-- Loyalty	      | social media	    | 1.53
-- Loyalty	      | affiliate	        | 1.06
-- Loyalty	      | unknown	          | 0.12
-- Non-Loyalty	  | direct 	          | 82.14
-- Non-Loyalty	  | email 	          | 13.12
-- Non-Loyalty	  | affiliate 	      | 3.63
-- Non-Loyalty	  | social media	    | 1.09
-- Non-Loyalty	  | unknown	          | 0.03

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
FROM 
  core.orders
  LEFT JOIN core.customers
    ON orders.customer_id = customers.id
WHERE loyalty_program IS NOT NULL
GROUP BY 
  customers.loyalty_program, 
  orders.purchase_platform
ORDER BY 
  loyalty_status,
  pct_used DESC;

SELECT *
  FROM 
  core.orders
  LEFT JOIN core.customers
    ON orders.customer_id = customers.id
WHERE loyalty_program IS NULL

-- Results:
-- loyalty_status	| purchase_platform |	pct_used
-- Loyalty	      | website	          | 77.66
-- Loyalty	      | mobile app	      | 22.34
-- Non-Loyalty	  | website 	        | 86.41
-- Non-Loyalty	  | mobile app	      | 13.59
