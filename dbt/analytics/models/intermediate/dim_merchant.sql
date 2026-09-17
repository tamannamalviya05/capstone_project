{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'MERCHANT_NAME',
           incremental_strategy = 'merge') }}

SELECT 
  MERCHANT_NAME,
  MERCHANT_CATEGORY

FROM {{ ref ('stg_banking_data') }}
WHERE MERCHANT_NAME IS NOT NULL 
QUALIFY ROW_NUMBER() OVER (PARTITION BY TRIM(MERCHANT_NAME) ORDER BY TRIM(MERCHANT_CATEGORY)) = 1