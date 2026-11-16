with source as (

    select * from {{ source('bronze', 'pedestrian_counts_raw') }}

),

deduplicated as (

    select *
    from source
    qualify row_number() over (
        partition by location_id, sensing_date, hourday
        order by ingested_at desc
    ) = 1

)

select
    concat_ws(
        '-',
        cast(location_id as string),
        date_format(sensing_date, 'yyyyMMdd'),
        lpad(cast(hourday as string), 2, '0')
    ) as count_id,
    cast(location_id as int) as location_id,
    sensing_date,
    cast(hourday as int) as hour_of_day,
    timestampadd(hour, hourday, cast(sensing_date as timestamp_ntz)) as counted_at,
    cast(direction_1 as int) as direction_1_count,
    cast(direction_2 as int) as direction_2_count,
    cast(pedestriancount as int) as total_count
from deduplicated
