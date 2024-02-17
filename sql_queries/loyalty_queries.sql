-- Calculate average days to deliver for loyalty vs. non-loyalty customers  
   SELECT CASE
               WHEN loyalty_program = 1 THEN 'Loyalty' ELSE 'Non-Loyalty'
           END AS loyalty_status
        , ROUND(AVG(DATE_DIFF(delivery_ts, ship_ts, DAY)), 2) AS avg_days_to_deliver
     FROM core.customers
LEFT JOIN core.orders
       ON customers.id = orders.customer_id
LEFT JOIN core.order_status
       ON orders.id = order_status.order_id
 GROUP BY loyalty_program
 ORDER BY 2 DESC;