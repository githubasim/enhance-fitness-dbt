select package_type_id, discount_band_pct
from {{ ref('mart_package_pricing') }}
where abs(list_revenue_aed - (net_sales_aed + discount_given_aed)) > 0.01