select
    payment_id,
    purchase_id,
    amount_aed,
    cast(payment_date as date) as payment_date,
    method as payment_method,
    status as payment_status
from {{ source('raw', 'payments') }}