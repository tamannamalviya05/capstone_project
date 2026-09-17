{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'ACCOUNT_ID',
           incremental_strategy = 'merge') }}
SELECT
  DISTINCT ACCOUNT_ID,
  ACCOUNT_TYPE,
  ACCOUNT_OPEN_DATE,
  ACCOUNT_STATUS

FROM {{ ref ('stg_banking_data') }}
WHERE ACCOUNT_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY ACCOUNT_ID ORDER BY ACCOUNT_ID) = 1