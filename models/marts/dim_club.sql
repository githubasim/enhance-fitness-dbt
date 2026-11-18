select
    club_id,
    club_name,
    pt_rooms,
    opened_date
from {{ ref('stg_clubs') }}