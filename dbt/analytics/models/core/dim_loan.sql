{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'LOAN_ID',
    incremental_strategy = 'merge'
) }}

SELECT
    MD5(TO_VARCHAR(LOAN_ID)) AS LOAN_SK,
    LOAN_ID,
    LOAN_TYPE,
    LOAN_AMOUNT,
    INTEREST_RATE,
    TENURE_MONTHS,
    LOAN_STATUS

FROM {{ ref('stg_banking_data') }}

WHERE LOAN_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY LOAN_ID
    ORDER BY _LOADED_AT DESC
) = 1