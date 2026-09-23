{% snapshot snap_dim_loan %}

{{
    config(
        target_schema='CORE',
        unique_key='LOAN_ID',
        strategy='check',
        check_cols=[
            'LOAN_TYPE',
            'LOAN_AMOUNT',
            'INTEREST_RATE',
            'TENURE_MONTHS',
            'LOAN_STATUS'
        ]
    )
}}

SELECT
    LOAN_ID,
    LOAN_TYPE,
    LOAN_AMOUNT,
    INTEREST_RATE,
    TENURE_MONTHS,
    LOAN_STATUS
FROM {{ ref('stg_banking_data') }}
WHERE LOAN_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY LOAN_ID
    ORDER BY _LOADED_AT DESC
) = 1

{% endsnapshot %}