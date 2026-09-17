{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'COMPLAINT_ID',
    incremental_strategy = 'merge'
) }}

SELECT
    COMPLAINT_ID,
    COMPLAINT_CATEGORY,
    COMPLAINT_PRIORITY,
    COMPLAINT_STATUS
FROM {{ ref('stg_banking_data') }}
WHERE COMPLAINT_ID IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY COMPLAINT_ID ORDER BY COMPLAINT_ID) = 1