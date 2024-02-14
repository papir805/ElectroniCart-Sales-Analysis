   SELECT CASE
               WHEN LOWER(product_name) LIKE '%apple%' THEN 'Apple'
               WHEN LOWER(product_name) LIKE '%samsung%' THEN 'Samsung'
               WHEN LOWER(product_name) LIKE '%thinkpad%' THEN 'ThinkPad'
          ELSE 'Unknown'
          END AS brand
        , DATE_TRUNC(refund_ts, MONTH) AS month
        , COUNT(refund_ts) AS refund_count
     FROM core.orders
LEFT JOIN core.order_status
       ON orders.id = order_status.order_id
    WHERE EXTRACT(YEAR FROM refund_ts) = 2020
 GROUP BY 1, 2
  QUALIFY ROW_NUMBER() OVER (PARTITION BY brand ORDER BY refund_count DESC) = 1
 ORDER BY 3 DESC;