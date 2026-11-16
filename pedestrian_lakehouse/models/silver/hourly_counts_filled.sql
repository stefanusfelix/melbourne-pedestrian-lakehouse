with observed as (

    select * from {{ ref('hourly_counts') }}

),

active_days as (

    select distinct
        location_id,
        sensing_date
    from observed

),

hours as (

    select explode(sequence(0, 23)) as hour_of_day

),

expected as (

    select
        active_days.location_id,
        active_days.sensing_date,
        hours.hour_of_day
    from active_days
    cross join hours

)

select
    concat_ws(
        '-',
        cast(expected.location_id as string),
        date_format(expected.sensing_date, 'yyyyMMdd'),
        lpad(cast(expected.hour_of_day as string), 2, '0')
    ) as count_id,
    expected.location_id,
    expected.sensing_date,
    expected.hour_of_day,
    timestampadd(
        hour,
        expected.hour_of_day,
        cast(expected.sensing_date as timestamp_ntz)
    ) as counted_at,
    coalesce(observed.direction_1_count, 0) as direction_1_count,
    coalesce(observed.direction_2_count, 0) as direction_2_count,
    coalesce(observed.total_count, 0) as total_count,
    observed.count_id is null as is_filled
from expected
left join observed
    on expected.location_id = observed.location_id
    and expected.sensing_date = observed.sensing_date
    and expected.hour_of_day = observed.hour_of_day
