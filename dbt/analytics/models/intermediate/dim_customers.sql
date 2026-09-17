{{ config (schema = 'CORE',
           materialized = 'incremental',
           unique_key = 'CUSTOMER_ID',
           incremental_strategy = 'merge') }}

SELECT 
   DISTINCT CUSTOMER_ID,
   CUSTOMER_NAME,
   CUSTOMER_DOB,
   CUSTOMER_GENDER,
   CUSTOMER_EMAIL,
   CUSTOMER_PHONE,
   CUSTOMER_CITY,
   CUSTOMER_COUNTRY,
   CUSTOMER_SEGMENT,
   KYC_STATUS,
   CUSTOMER_ANNUAL_INCOME,
   CREDIT_SCORE

FROM {{ ref ('stg_banking_data')}}
WHERE CUSTOMER_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (PARTITION BY CUSTOMER_ID ORDER BY CUSTOMER_ID) = 1