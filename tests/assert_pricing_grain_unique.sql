select package_type_id, discount_band_pct, count(*) as n
from {{ ref('mart_package_pricing') }}
group by 1, 2
having count(*) > 1