{% snapshot snap_dim_payments %}

{{
    config(
        target_schema='CORE',
        unique_key="CONCAT(PAYMENT_CHANNEL, '|', PAYMENT_METHOD)",
        strategy='check',
        check_cols=[
            'PAYMENT_CHANNEL',
            'PAYMENT_METHOD'
        ]
    )
}}

SELECT DISTINCT
    UPPER(TRIM(PAYMENT_CHANNEL)) AS PAYMENT_CHANNEL,
    UPPER(TRIM(PAYMENT_METHOD)) AS PAYMENT_METHOD
FROM {{ ref('stg_banking_data') }}
WHERE PAYMENT_CHANNEL IS NOT NULL
  AND PAYMENT_METHOD IS NOT NULL

{% endsnapshot %}