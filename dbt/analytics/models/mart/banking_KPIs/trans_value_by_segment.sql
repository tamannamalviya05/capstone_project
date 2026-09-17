{{ config (schema = 'MART',
           materialized = 'view')}}

SELECT c.CUSTOMER_SEGMENT,
       COUNT(t.*) AS TRANSACTION_COUNT,
       SUM(t.AMOUNT) AS TOTAL_TRANSACTION_VALUE,
       ROUND(AVG(t.AMOUNT), 2) AS AVG_TRANSACTION_VALUE
FROM {{ ref ('fact_transaction') }} AS t
JOIN {{ ref ('dim_customers') }} AS c ON t.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY c.CUSTOMER_SEGMENT
ORDER BY TOTAL_TRANSACTION_VALUE DESC