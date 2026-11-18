select
    club_id,
    club_name,
    pt_rooms,
    cast(opened_date as date) as opened_date
from {{ source('raw', 'clubs') }}