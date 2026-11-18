with purchases as (
    select
        *,
        row_number() over (
            partition by client_id order by purchase_date, purchase_id
        ) as purchase_number
    from {{ ref('stg_purchases') }}
),

payments as (
    select
        purchase_id,
        sum(case when payment_status = 'paid' then amount_aed else 0 end) as paid_amount_aed,
        max(case when payment_status = 'refunded' then 1 else 0 end) = 1 as is_refunded
    from {{ ref('stg_payments') }}
    group by purchase_id
),

session_agg as (
    select
        purchase_id,
        count(*) filter (where session_status = 'delivered') as sessions_delivered,
        count(*) filter (where session_status = 'cancelled') as sessions_cancelled,
        count(*) filter (where session_status = 'no_show') as sessions_no_show,
        count(*) filter (where session_status = 'booked') as sessions_booked,
        sum(recognised_revenue_aed) as recognised_revenue_aed,
        sum(commission_aed) as commission_aed
    from {{ ref('int_sessions_enriched') }}
    group by purchase_id
)

select
    p.purchase_id,
    p.client_id,
    p.package_type_id,
    p.trainer_id,
    p.club_id,
    cast(strftime(p.purchase_date, '%Y%m%d') as integer) as purchase_date_key,
    p.purchase_number,
    p.purchase_number > 1 as is_renewal,
    pk.sessions_included,
    p.list_price_aed,
    p.discount_pct,
    p.list_price_aed - p.net_price_aed as discount_amount_aed,
    p.net_price_aed,
    pay.paid_amount_aed,
    pay.is_refunded,
    coalesce(s.sessions_delivered, 0) as sessions_delivered,
    coalesce(s.sessions_cancelled, 0) as sessions_cancelled,
    coalesce(s.sessions_no_show, 0) as sessions_no_show,
    coalesce(s.sessions_booked, 0) as sessions_booked,
    coalesce(s.sessions_delivered, 0) + coalesce(s.sessions_no_show, 0) as sessions_consumed,
    coalesce(s.recognised_revenue_aed, 0) as recognised_revenue_aed,
    coalesce(s.commission_aed, 0) as commission_aed,
    coalesce(s.recognised_revenue_aed, 0) - coalesce(s.commission_aed, 0) as margin_aed
from purchases p
left join {{ ref('stg_package_types') }} pk on p.package_type_id = pk.package_type_id
left join payments pay on p.purchase_id = pay.purchase_id
left join session_agg s on p.purchase_id = s.purchase_id