select
    trainer_id,
    club_id,
    commission_rate,
    weekly_available_hours,
    hire_date
from {{ ref('stg_trainers') }}