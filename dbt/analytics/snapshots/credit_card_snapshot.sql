{% snapshot snap_dim_credit_card %}

{{
    config(
        target_schema='CORE',
        unique_key='CREDIT_CARD_ID',
        strategy='check',
        check_cols=[
            'CARD_TYPE',
            'CARD_NETWORK',
            'CREDIT_LIMIT',
            'CARD_STATUS'
        ]
    )
}}

SELECT
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

{% endsnapshot %}