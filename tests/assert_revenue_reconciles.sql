with s as (select sum(recognised_revenue_aed) as total from {{ ref('fct_sessions') }}),
     p as (select sum(recognised_revenue_aed) as total from {{ ref('fct_packages') }})

select s.total as sessions_total, p.total as packages_total
from s cross join p
where abs(s.total - p.total) > 1