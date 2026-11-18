select
    purchase_id,
    client_id,
    package_type_id,
    trainer_id,
    club_id,
    cast(purchase_date as date) as purchase_date,
    list_price_aed,
    discount_pct,
    net_price_aed
from {{ source('raw', 'purchases') }}