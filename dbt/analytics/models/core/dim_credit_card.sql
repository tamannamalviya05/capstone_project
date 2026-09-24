{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'CREDIT_CARD_ID',
    incremental_strategy = 'merge'
) }}

SELECT
    MD5(TO_VARCHAR(CREDIT_CARD_ID)) AS CREDIT_CARD_SK,
    CREDIT_CARD_ID,
    CARD_TYPE,
    CARD_NETWORK,
    CREDIT_LIMIT,
    CARD_STATUS

FROM {{ ref('stg_banking_data') }}

WHERE CREDIT_CARD_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY CREDIT_CARD_ID
    ORDER BY _LOADED_AT DESC
) = 1