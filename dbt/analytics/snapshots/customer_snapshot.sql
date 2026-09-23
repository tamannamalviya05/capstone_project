{% snapshot snap_dim_customers %}

{{
    config(
        target_schema='CORE',
        unique_key='CUSTOMER_ID',
        strategy='check',
        check_cols=[
            'CUSTOMER_NAME',
            'CUSTOMER_DOB',
            'CUSTOMER_GENDER',
            'CUSTOMER_EMAIL',
            'CUSTOMER_PHONE',
            'CUSTOMER_CITY',
            'CUSTOMER_COUNTRY',
            'CUSTOMER_SEGMENT',
            'KYC_STATUS',
            'CUSTOMER_ANNUAL_INCOME',
            'CREDIT_SCORE'
        ]
    )
}}

SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    CUSTOMER_DOB,
    CUSTOMER_GENDER,
    CUSTOMER_EMAIL,
    CUSTOMER_PHONE,
    CUSTOMER_CITY,
    CUSTOMER_COUNTRY,
    CUSTOMER_SEGMENT,
    KYC_STATUS,
    CUSTOMER_ANNUAL_INCOME,
    CREDIT_SCORE
FROM {{ ref('stg_banking_data') }}
WHERE CUSTOMER_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY CUSTOMER_ID
    ORDER BY _LOADED_AT DESC
) = 1

{% endsnapshot %}