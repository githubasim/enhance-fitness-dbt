with client_sessions as (
    select
        session_id,
        client_id,
        club_id,
        scheduled_at,
        session_status,
        lead(scheduled_at) over (
            partition by client_id order by scheduled_at, session_id
        ) as next_scheduled_at
    from {{ ref('fct_sessions') }}
    where session_status in ('delivered', 'no_show', 'booked')
),

matured as (
    select
        *,
        next_scheduled_at is not null
            and next_scheduled_at <= scheduled_at + interval 14 day as rebooked_within_14d
    from client_sessions
    where session_status = 'delivered'
      and scheduled_at <= current_timestamp - interval 14 day
)

select
    club_id,
    cast(date_trunc('month', scheduled_at) as date) as month_start,
    count(*) as delivered_sessions,
    count(*) filter (where rebooked_within_14d) as rebooked_sessions,
    round(count(*) filter (where rebooked_within_14d) * 1.0 / count(*), 4) as rebooking_rate_14d
from matured
group by 1, 2