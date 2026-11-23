select club_id, month_start, rebooking_rate_14d
from {{ ref('mart_rebooking_rate') }}
where rebooking_rate_14d < 0 or rebooking_rate_14d > 1