with sessions as (
    select * from {{ ref('stg_sessions') }}
),

purchases as (
    select * from {{ ref('stg_purchases') }}
),

packages as (
    select * from {{ ref('stg_package_types') }}
),

trainers as (
    select * from {{ ref('stg_trainers') }}
),

refunds as (
    select
        purchase_id,
        max(case when payment_status = 'refunded' then 1 else 0 end) = 1 as is_refunded
    from {{ ref('stg_payments') }}
    group by purchase_id
),

joined as (
    select
        s.session_id,
        s.purchase_id,
        s.client_id,
        s.trainer_id,
        s.club_id,
        s.booked_at,
        s.scheduled_at,
        cast(s.scheduled_at as date) as session_date,
        s.duration_min,
        s.session_status,
        pk.package_type_id,
        pk.package_name,
        pk.sessions_included,
        pu.list_price_aed,
        pu.discount_pct,
        pu.net_price_aed,
        round(pu.net_price_aed / pk.sessions_included, 2) as price_per_session_aed,
        coalesce(r.is_refunded, false) as is_refunded,
        t.commission_rate,
        t.hire_date as trainer_hire_date
    from sessions s
    left join purchases pu on s.purchase_id = pu.purchase_id
    left join packages pk on pu.package_type_id = pk.package_type_id
    left join trainers t on s.trainer_id = t.trainer_id
    left join refunds r on s.purchase_id = r.purchase_id
)

select
    *,
    session_status in ('delivered', 'no_show') as is_consumed,
    cast(scheduled_at as date) < trainer_hire_date as is_before_trainer_hire,
    case
        when session_status in ('delivered', 'no_show') and not is_refunded
        then price_per_session_aed else 0
    end as recognised_revenue_aed,
    case
        when session_status = 'delivered' and not is_refunded
        then round(price_per_session_aed * commission_rate, 2) else 0
    end as commission_aed
from joined