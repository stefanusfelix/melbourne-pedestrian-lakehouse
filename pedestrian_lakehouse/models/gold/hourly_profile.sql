with hourly as (

    select * from {{ ref('hourly_counts_filled') }}

),

daily as (

    select * from {{ ref('daily_location_summary') }}

),

reliable_hours as (

    select
        hourly.*,
        daily.sensor_name
    from hourly
    inner join daily
        on hourly.location_id = daily.location_id
        and hourly.sensing_date = daily.sensing_date
    where not daily.has_daytime_gap

)

select
    location_id,
    sensor_name,
    case
        when weekday(sensing_date) >= 5 then 'weekend'
        else 'weekday'
    end as day_type,
    hour_of_day,
    round(avg(total_count), 1) as avg_total_count,
    round(avg(direction_1_count), 1) as avg_direction_1_count,
    round(avg(direction_2_count), 1) as avg_direction_2_count,
    count(*) as readings
from reliable_hours
group by all
