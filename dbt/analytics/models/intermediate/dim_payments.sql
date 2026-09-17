{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'PAYMENT_KEY',
           incremental_strategy = 'merge') }}

SELECT 
  DISTINCT PAYMENT_CHANNEL,
  PAYMENT_METHOD,
  CONCAT(PAYMENT_CHANNEL, '_', PAYMENT_METHOD) AS PAYMENT_KEY
FROM {{ ref ('stg_banking_data') }}
WHERE PAYMENT_CHANNEL IS NOT NULL AND PAYMENT_METHOD IS NOT NULL 