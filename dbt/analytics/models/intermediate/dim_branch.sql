{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'BRANCH_ID',
    incremental_strategy = 'merge'
) }}

SELECT
    MD5(TO_VARCHAR(BRANCH_ID)) AS BRANCH_SK,
    BRANCH_ID,
    BRANCH_NAME

FROM {{ ref('stg_banking_data') }}

WHERE BRANCH_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY BRANCH_ID
    ORDER BY _LOADED_AT DESC
) = 1