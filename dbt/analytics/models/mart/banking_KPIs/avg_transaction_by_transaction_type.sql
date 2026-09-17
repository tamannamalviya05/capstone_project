{{ config (schema = 'MART',
           materialized = 'view')}}

SELECT TRANSACTION_TYPE,
       ROUND(AVG(AMOUNT), 2) AS AVG_AMOUNT
FROM {{ ref ('fact_transaction') }}
GROUP BY TRANSACTION_TYPE
