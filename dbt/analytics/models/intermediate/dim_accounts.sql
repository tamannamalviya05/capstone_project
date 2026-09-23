{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'ACCOUNT_ID',
    incremental_strategy = 'merge'
) }}

SELECT
    MD5(TO_VARCHAR(ACCOUNT_ID)) AS ACCOUNT_SK,
    ACCOUNT_ID,
    ACCOUNT_TYPE,
    ACCOUNT_OPEN_DATE,
    ACCOUNT_STATUS

FROM {{ ref('stg_banking_data') }}

WHERE ACCOUNT_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ACCOUNT_ID
    ORDER BY _LOADED_AT DESC
) = 1