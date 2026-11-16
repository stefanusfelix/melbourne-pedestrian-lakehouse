with hourly as (

    select * from {{ ref('hourly_counts_filled') }}

),

sensors as (

    select * from {{ ref('sensors') }}

),

daily as (

    select
        location_id,
        sensing_date,
        sum(total_count) as total_count,
        sum(direction_1_count) as direction_1_count,
        sum(direction_2_count) as direction_2_count,
        count_if(not is_filled) as hours_reported,
        count_if(is_filled and hour_of_day between 7 and 17) as missing_daytime_hours,
        max_by(hour_of_day, total_count) as peak_hour,
        max(total_count) as peak_hour_count
    from hourly
    group by location_id, sensing_date

)

select
    daily.location_id,
    sensors.sensor_name,
    daily.sensing_date,
    date_format(daily.sensing_date, 'EEEE') as day_name,
    weekday(daily.sensing_date) >= 5 as is_weekend,
    daily.total_count,
    daily.direction_1_count,
    daily.direction_2_count,
    daily.peak_hour,
    daily.peak_hour_count,
    daily.hours_reported,
    daily.missing_daytime_hours,
    daily.missing_daytime_hours > 0 as has_daytime_gap,
    round(
        avg(daily.total_count) over (
            partition by daily.location_id
            order by daily.sensing_date
            range between interval 6 days preceding and current row
        ),
        1
    ) as rolling_7_day_avg
from daily
inner join sensors
    on daily.location_id = sensors.location_id
