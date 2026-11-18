select
    session_id,
    purchase_id,
    client_id,
    trainer_id,
    club_id,
    cast(booked_at as timestamp) as booked_at,
    cast(scheduled_at as timestamp) as scheduled_at,
    duration_min,
    status as session_status
from {{ source('raw', 'sessions') }}