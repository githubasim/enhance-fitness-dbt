select
    trainer_id,
    club_id,
    commission_rate,
    weekly_available_hours,
    cast(hire_date as date) as hire_date
from {{ source('raw', 'trainers') }}