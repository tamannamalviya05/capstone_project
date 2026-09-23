{% snapshot snap_dim_accounts %}

{{
    config(
        target_schema='CORE',
        unique_key='ACCOUNT_ID',
        strategy='check',
        check_cols=[
            'ACCOUNT_TYPE',
            'ACCOUNT_OPEN_DATE',
            'ACCOUNT_STATUS'
        ]
    )
}}

SELECT
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

{% endsnapshot %}