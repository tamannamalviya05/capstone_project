{{ config(
    schema = 'CORE',
    materialized = 'incremental',
    unique_key = 'TRANSACTION_ID',
    incremental_strategy = 'merge'
) }}

SELECT
    t.TRANSACTION_ID,
    t.TRANSACTION_DATE,
    d.DATE_KEY,
    t.TRANSACTION_TYPE,
    t.AMOUNT,
    t.CURRENCY,
    t.TRANSACTION_STATUS,
    a.ACCOUNT_SK,
    t.ACCOUNT_ID,
    b.BRANCH_SK,
    t.BRANCH_ID,
    c.CUSTOMER_SK,
    t.CUSTOMER_ID,
    cc.CREDIT_CARD_SK,
    t.CREDIT_CARD_ID,
    l.LOAN_SK,
    t.LOAN_ID,
    cp.COMPLAINT_SK,
    t.COMPLAINT_ID,
    m.MERCHANT_SK,
    t.MERCHANT_NAME,
    p.PAYMENT_SK,
    t.RUNNING_BALANCE,
    t.IS_FLAGGED_FRAUD

FROM {{ ref('stg_banking_data') }} t
LEFT JOIN {{ ref('dim_date') }} d ON TO_DATE(t.TRANSACTION_DATE) = d.DATE_DAY
LEFT JOIN {{ ref('dim_accounts') }} a ON t.ACCOUNT_ID = a.ACCOUNT_ID
LEFT JOIN {{ ref('dim_branch') }} b ON t.BRANCH_ID = b.BRANCH_ID
LEFT JOIN {{ ref('dim_customers') }} c ON t.CUSTOMER_ID = c.CUSTOMER_ID
LEFT JOIN {{ ref('dim_credit_card') }} cc ON t.CREDIT_CARD_ID = cc.CREDIT_CARD_ID
LEFT JOIN {{ ref('dim_loan') }} l ON t.LOAN_ID = l.LOAN_ID
LEFT JOIN {{ ref('dim_complaint') }} cp ON t.COMPLAINT_ID = cp.COMPLAINT_ID
LEFT JOIN {{ ref('dim_merchant') }} m ON TRIM(t.MERCHANT_NAME) = TRIM(m.MERCHANT_NAME)
LEFT JOIN {{ ref('dim_payments') }} p ON UPPER(TRIM(t.PAYMENT_CHANNEL)) = UPPER(TRIM(p.PAYMENT_CHANNEL))
   AND UPPER(TRIM(t.PAYMENT_METHOD)) = UPPER(TRIM(p.PAYMENT_METHOD))
WHERE t.TRANSACTION_ID IS NOT NULL

QUALIFY ROW_NUMBER() OVER (
    PARTITION BY t.TRANSACTION_ID
    ORDER BY t._LOADED_AT DESC
) = 1