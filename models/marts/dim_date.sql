with days as (
    select cast(d as date) as date_day
    from generate_series(date '2022-01-01', date '2028-12-31', interval 1 day) as t(d)
)

select
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    date_day,
    year(date_day) as year_number,
    month(date_day) as month_number,
    strftime(date_day, '%b') as month_name,
    cast(date_trunc('month', date_day) as date) as month_start,
    isodow(date_day) as day_of_week_number,
    strftime(date_day, '%a') as day_name,
    isodow(date_day) in (6, 7) as is_weekend
from days