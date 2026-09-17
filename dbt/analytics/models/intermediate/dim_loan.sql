{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'LOAN_ID',
           incremental_strategy = 'merge') }}

SELECT 
  DISTINCT LOAN_ID,
  LOAN_TYPE,
  LOAN_AMOUNT,
  INTEREST_RATE,
  TENURE_MONTHS,
  LOAN_STATUS

FROM {{ ref ('stg_banking_data')}}
WHERE LOAN_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY LOAN_ID ORDER BY LOAN_ID) = 1