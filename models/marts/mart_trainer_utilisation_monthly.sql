with months as (
    select distinct month_start
    from {{ ref('dim_date') }}
    where month_start >= date '2022-01-01'
      and month_start < cast(date_trunc('month', current_date) as date)
),

trainer_months as (
    select
        t.trainer_id,
        t.club_id,
        m.month_start,
        round(t.weekly_available_hours * 52.0 / 12, 1) as available_hours
    from {{ ref('dim_trainer') }} t
    join {{ ref('dim_club') }} c on t.club_id = c.club_id
    join months m
        on m.month_start >= cast(date_trunc('month', greatest(t.hire_date, c.opened_date)) as date)
),

session_hours as (
    select
        trainer_id,
        cast(date_trunc('month', scheduled_at) as date) as month_start,
        coalesce(sum(duration_min) filter (where session_status = 'delivered'), 0) / 60.0 as delivered_hours,
        coalesce(sum(duration_min) filter (where session_status = 'no_show'), 0) / 60.0 as no_show_hours,
        coalesce(sum(duration_min) filter (where session_status = 'cancelled'), 0) / 60.0 as cancelled_hours
    from {{ ref('fct_sessions') }}
    group by 1, 2
)

select
    tm.trainer_id,
    tm.club_id,
    tm.month_start,
    tm.available_hours,
    coalesce(sh.delivered_hours, 0) as delivered_hours,
    coalesce(sh.no_show_hours, 0) as no_show_hours,
    coalesce(sh.cancelled_hours, 0) as cancelled_hours,
    round(coalesce(sh.delivered_hours, 0) / tm.available_hours, 4) as utilisation_pct,
    greatest(
        tm.available_hours - coalesce(sh.delivered_hours, 0) - coalesce(sh.no_show_hours, 0), 0
    ) as idle_hours
from trainer_months tm
left join session_hours sh
    on tm.trainer_id = sh.trainer_id and tm.month_start = sh.month_start