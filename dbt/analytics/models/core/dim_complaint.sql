{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'COMPLAINT_ID',
    incremental_strategy = 'merge'
) }}
SELECT
    MD5(TO_VARCHAR(COMPLAINT_ID)) AS COMPLAINT_SK,
    COMPLAINT_ID,
    COMPLAINT_CATEGORY,
    COMPLAINT_PRIORITY,
    COMPLAINT_STATUS
FROM {{ ref('stg_banking_data') }}
WHERE COMPLAINT_ID IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY COMPLAINT_ID ORDER BY _LOADED_AT DESC) = 1