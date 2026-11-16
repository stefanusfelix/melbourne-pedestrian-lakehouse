select
    count_id,
    direction_1_count,
    direction_2_count,
    total_count
from {{ ref('hourly_counts') }}
where total_count != direction_1_count + direction_2_count
