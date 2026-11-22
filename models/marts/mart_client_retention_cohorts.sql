with cohort_size as (
    select cohort_month, count(*) as cohort_clients
    from {{ ref('dim_client') }}
    where cohort_month is not null
    group by 1
),

activity as (
    select distinct
        c.cohort_month,
        c.client_id,
        cast(date_trunc('month', s.scheduled_at) as date) as activity_month
    from {{ ref('fct_sessions') }} s
    join {{ ref('dim_client') }} c on s.client_id = c.client_id
    where s.session_status = 'delivered'
      and c.cohort_month is not null
),

cohort_activity as (
    select
        cohort_month,
        date_diff('month', cohort_month, activity_month) as months_since_first_purchase,
        count(distinct client_id) as active_clients
    from activity
    where activity_month < cast(date_trunc('month', current_date) as date)
    group by 1, 2
)

select
    ca.cohort_month,
    ca.months_since_first_purchase,
    cs.cohort_clients,
    ca.active_clients,
    round(ca.active_clients * 1.0 / cs.cohort_clients, 4) as retention_pct
from cohort_activity ca
join cohort_size cs on ca.cohort_month = cs.cohort_month
where ca.months_since_first_purchase >= 0