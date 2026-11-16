with sensors as (

    select * from {{ ref('sensors') }}

),

expected_days as (

    select
        location_id,
        sensor_name,
        explode(
            sequence(first_reading_date, last_reading_date, interval 1 day)
        ) as sensing_date
    from sensors

),

daily as (

    select * from {{ ref('daily_location_summary') }}

)

select
    expected_days.location_id,
    expected_days.sensor_name,
    expected_days.sensing_date,
    coalesce(daily.hours_reported, 0) as hours_reported,
    coalesce(daily.missing_daytime_hours, 11) as missing_daytime_hours,
    case
        when daily.location_id is null then 'offline'
        when daily.has_daytime_gap then 'daytime_gap'
        else 'reporting'
    end as day_status
from expected_days
left join daily
    on expected_days.location_id = daily.location_id
    and expected_days.sensing_date = daily.sensing_date
