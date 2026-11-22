with packages as (
    select
        p.purchase_id,
        p.client_id,
        p.package_type_id,
        p.purchase_number,
        d.date_day as purchase_date,
        pt.package_name,
        pt.validity_days
    from {{ ref('fct_packages') }} p
    join {{ ref('dim_date') }} d on p.purchase_date_key = d.date_key
    join {{ ref('dim_package_type') }} pt on p.package_type_id = pt.package_type_id
),

with_next as (
    select
        *,
        lead(purchase_id) over (
            partition by client_id order by purchase_number
        ) as next_purchase_id
    from packages
)

select
    package_type_id,
    package_name,
    count(*) as matured_packages,
    count(next_purchase_id) as renewed_packages,
    round(count(next_purchase_id) * 1.0 / count(*), 4) as renewal_rate
from with_next
where purchase_number < 4  -- generator caps clients at 4 purchases, so #4 can never renew
  and purchase_date + cast(ceil(validity_days * 1.1) as integer) <= current_date
group by 1, 2