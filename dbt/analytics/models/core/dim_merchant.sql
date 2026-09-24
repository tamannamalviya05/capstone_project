{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'MERCHANT_NAME',
    incremental_strategy = 'merge'
) }}

SELECT
    MD5(TO_VARCHAR(TRIM(MERCHANT_NAME))) AS MERCHANT_SK,
    TRIM(MERCHANT_NAME) AS MERCHANT_NAME,
    MERCHANT_CATEGORY

FROM {{ ref('stg_banking_data') }}

WHERE MERCHANT_NAME IS NOT NULL
  AND TRIM(MERCHANT_NAME) <> ''

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY TRIM(MERCHANT_NAME)
    ORDER BY _LOADED_AT DESC
) = 1