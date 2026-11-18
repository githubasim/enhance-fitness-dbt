select
    client_id,
    home_club_id,
    cast(signup_date as date) as signup_date,
    acquisition_channel
from {{ source('raw', 'clients') }}