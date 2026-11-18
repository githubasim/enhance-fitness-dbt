with first_purchase as (
    select client_id, min(purchase_date) as first_purchase_date
    from {{ ref('stg_purchases') }}
    group by client_id
)

select
    c.client_id,
    c.home_club_id,
    c.signup_date,
    c.acquisition_channel,
    fp.first_purchase_date,
    cast(date_trunc('month', fp.first_purchase_date) as date) as cohort_month
from {{ ref('stg_clients') }} c
left join first_purchase fp on c.client_id = fp.client_id