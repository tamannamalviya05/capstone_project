{{ config (schema = 'MART',
           materialized = 'view')}}

SELECT COUNT(t.*) AS TRANSACTION_COUNT,
       p.PAYMENT_METHOD
FROM {{ ref ('fact_transaction') }} AS t
JOIN {{ ref ('dim_payments') }} AS p ON p.PAYMENT_KEY = t.PAYMENT_KEY
GROUP BY p.PAYMENT_METHOD
ORDER BY TRANSACTION_COUNT DESC