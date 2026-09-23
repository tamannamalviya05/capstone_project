{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'PAYMENT_KEY',
           incremental_strategy = 'merge') }}

SELECT DISTINCT 
  MD5(
      CONCAT(
          UPPER(TRIM(PAYMENT_CHANNEL)),
          '|',
          UPPER(TRIM(PAYMENT_METHOD))
        )
    ) AS PAYMENT_SK,
  CONCAT( UPPER(TRIM(PAYMENT_CHANNEL)), '_', UPPER(TRIM(PAYMENT_METHOD)) ) AS PAYMENT_KEY,
  PAYMENT_CHANNEL,
  PAYMENT_METHOD,
FROM {{ ref ('stg_banking_data') }}
WHERE PAYMENT_CHANNEL IS NOT NULL AND PAYMENT_METHOD IS NOT NULL 