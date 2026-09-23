{% snapshot snap_dim_complaint %}

{{
    config(
        target_schema='CORE',
        unique_key='COMPLAINT_ID',
        strategy='check',
        check_cols=[
            'COMPLAINT_CATEGORY',
            'COMPLAINT_PRIORITY',
            'COMPLAINT_STATUS'
        ]
    )
}}

SELECT
    COMPLAINT_ID,
    COMPLAINT_CATEGORY,
    COMPLAINT_PRIORITY,
    COMPLAINT_STATUS
FROM {{ ref('stg_banking_data') }}
WHERE COMPLAINT_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY COMPLAINT_ID
    ORDER BY _LOADED_AT DESC
) = 1

{% endsnapshot %}