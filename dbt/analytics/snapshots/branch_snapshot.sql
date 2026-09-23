{% snapshot snap_dim_branch %}

{{
    config(
        target_schema='CORE',
        unique_key='BRANCH_ID',
        strategy='check',
        check_cols=[
            'BRANCH_NAME'
        ]
    )
}}

SELECT
    BRANCH_ID,
    BRANCH_NAME
FROM {{ ref('stg_banking_data') }}
WHERE BRANCH_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY BRANCH_ID
    ORDER BY _LOADED_AT DESC
) = 1

{% endsnapshot %}