with source as (

    select * from {{ source('bronze', 'pedestrian_counts_raw') }}

),

latest_reading as (

    select *
    from source
    qualify row_number() over (
        partition by location_id
        order by sensing_date desc, hourday desc
    ) = 1

),

reading_span as (

    select
        location_id,
        min(sensing_date) as first_reading_date,
        max(sensing_date) as last_reading_date
    from source
    group by location_id

)

select
    cast(latest_reading.location_id as int) as location_id,
    latest_reading.sensor_name,
    try_cast(trim(split_part(latest_reading.location, ',', 1)) as double) as latitude,
    try_cast(trim(split_part(latest_reading.location, ',', 2)) as double) as longitude,
    reading_span.first_reading_date,
    reading_span.last_reading_date
from latest_reading
inner join reading_span
    on latest_reading.location_id = reading_span.location_id
