with trainer_sessions as (
    select
        s.trainer_id,
        t.club_id,
        count(*) filter (where s.is_consumed) as sessions_consumed,
        count(*) filter (where s.session_status = 'delivered') as sessions_delivered,
        count(*) filter (where s.is_before_trainer_hire) as sessions_before_hire,
        sum(s.recognised_revenue_aed) as recognised_revenue_aed,
        sum(s.commission_aed) as commission_aed,
        sum(s.margin_aed) as margin_aed
    from {{ ref('fct_sessions') }} s
    join {{ ref('dim_trainer') }} t on s.trainer_id = t.trainer_id
    where not s.is_refunded
    group by 1, 2
)

select
    trainer_id,
    club_id,
    sessions_consumed,
    sessions_delivered,
    sessions_before_hire,
    recognised_revenue_aed,
    commission_aed,
    margin_aed,
    round(margin_aed / nullif(sessions_consumed, 0), 2) as margin_per_consumed_session_aed,
    rank() over (partition by club_id order by margin_aed desc) as margin_rank_in_club,
    round(margin_aed / sum(margin_aed) over (partition by club_id), 4) as share_of_club_margin
from trainer_sessions