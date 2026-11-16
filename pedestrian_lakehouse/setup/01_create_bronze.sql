CREATE OR REPLACE TABLE pedestrian.bronze.pedestrian_counts_raw AS
SELECT
  *,
  _metadata.file_name AS source_file,
  current_timestamp() AS ingested_at
FROM read_files(
  '/Volumes/pedestrian/bronze/landing/',
  format => 'csv',
  header => true
);
