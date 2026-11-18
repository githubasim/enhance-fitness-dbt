select
    package_type_id,
    package_name,
    sessions_included,
    list_price_aed,
    validity_days
from {{ source('raw', 'package_types') }}