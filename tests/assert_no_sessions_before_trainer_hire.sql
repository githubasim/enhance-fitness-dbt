{{ config(severity='warn') }}

select
    session_id,
    trainer_id,
    session_date,
    trainer_hire_date
from {{ ref('int_sessions_enriched') }}
where is_before_trainer_hire