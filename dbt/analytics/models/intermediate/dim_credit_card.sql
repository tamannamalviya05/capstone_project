{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'CREDIT_CARD_ID',
           incremental_strategy = 'merge') }}
SELECT 
  DISTINCT CREDIT_CARD_ID,
  CARD_TYPE,
  CARD_NETWORK,
  CREDIT_LIMIT,
  CARD_STATUS
FROM {{ ref('stg_banking_data') }}
WHERE CREDIT_CARD_ID IS NOT NULL 

QUALIFY ROW_NUMBER() OVER (PARTITION BY CREDIT_CARD_ID ORDER BY CREDIT_CARD_ID) = 1
