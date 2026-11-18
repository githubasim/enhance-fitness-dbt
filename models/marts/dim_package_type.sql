select
    package_type_id,
    package_name,
    sessions_included,
    list_price_aed,
    round(list_price_aed / sessions_included, 2) as list_price_per_session_aed,
    validity_days
from {{ ref('stg_package_types') }}