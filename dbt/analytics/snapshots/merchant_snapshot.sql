{% snapshot snap_dim_merchant %}

{{
    config(
        target_schema='CORE',
        unique_key='MERCHANT_NAME',
        strategy='check',
        check_cols=[
            'MERCHANT_CATEGORY'
        ]
    )
}}

SELECT
    TRIM(MERCHANT_NAME) AS MERCHANT_NAME,
    MERCHANT_CATEGORY
FROM {{ ref('stg_banking_data') }}
WHERE MERCHANT_NAME IS NOT NULL
  AND TRIM(MERCHANT_NAME) <> ''

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY TRIM(MERCHANT_NAME)
    ORDER BY TRIM(MERCHANT_CATEGORY)
) = 1

{% endsnapshot %}