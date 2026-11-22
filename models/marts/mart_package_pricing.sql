with packages as (
    select
        p.purchase_id,
        p.package_type_id,
        pt.package_name,
        cast(round(p.discount_pct * 100) as integer) as discount_band_pct,
        p.list_price_aed,
        p.discount_amount_aed,
        p.net_price_aed,
        p.is_refunded,
        p.sessions_consumed,
        p.recognised_revenue_aed,
        p.commission_aed,
        p.margin_aed
    from {{ ref('fct_packages') }} p
    join {{ ref('dim_package_type') }} pt on p.package_type_id = pt.package_type_id
)

select
    package_type_id,
    package_name,
    discount_band_pct,
    count(*) as packages_sold,
    round(avg(case when is_refunded then 1.0 else 0.0 end), 4) as refund_rate,
    sum(list_price_aed) as list_revenue_aed,
    sum(discount_amount_aed) as discount_given_aed,
    sum(net_price_aed) as net_sales_aed,
    sum(sessions_consumed) filter (where not is_refunded) as sessions_consumed,
    sum(recognised_revenue_aed) filter (where not is_refunded) as recognised_revenue_aed,
    sum(commission_aed) filter (where not is_refunded) as commission_aed,
    round(
        sum(recognised_revenue_aed) filter (where not is_refunded)
        / nullif(sum(sessions_consumed) filter (where not is_refunded), 0), 2
    ) as revenue_per_consumed_session_aed,
    round(
        sum(margin_aed) filter (where not is_refunded)
        / nullif(sum(sessions_consumed) filter (where not is_refunded), 0), 2
    ) as margin_per_consumed_session_aed
from packages
group by 1, 2, 3