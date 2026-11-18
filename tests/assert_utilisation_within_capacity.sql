{{ config(severity='warn') }}

select trainer_id, month_start, delivered_hours, available_hours
from {{ ref('mart_trainer_utilisation_monthly') }}
where delivered_hours > available_hours