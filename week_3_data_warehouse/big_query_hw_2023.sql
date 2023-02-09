-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `ny-rides-shanu.dezoomcamp.external_fhv_trips`
OPTIONS (
  format = 'CSV',
  uris = ['gs://de-zoomcamp-2023/data/fhv/fhv_tripdata_2019-*.csv.gz']
);

-- Finding total count of entire dataset
-- Query result: 43244696
SELECT COUNT(*) FROM `ny-rides-shanu.dezoomcamp.external_fhv_trips`;

-- Creating internal table from external table
CREATE OR REPLACE TABLE `ny-rides-shanu.dezoomcamp.fhv_trips` AS
  SELECT * FROM `ny-rides-shanu.dezoomcamp.external_fhv_trips`;


-- Counting distinct number of affiliated_base_number on external table
-- Estimated 0 MB of data when processed
-- Query result - 3163
SELECT COUNT(DISTINCT Affiliated_base_number) FROM `ny-rides-shanu.dezoomcamp.external_fhv_trips`;

-- Counting distinct number of affiliated_base_number on internal table
-- Estimated 317.94 MB of data when processed
-- Query result - 3163
SELECT COUNT(DISTINCT Affiliated_base_number) FROM `ny-rides-shanu.dezoomcamp.fhv_trips`;


-- Counting blank PUlocationID and DOlocationID in entire dataset
-- 717748
SELECT COUNT(*) FROM `ny-rides-shanu.dezoomcamp.fhv_trips`
  WHERE PUlocationID IS NULL AND DOlocationID IS NULL;


-- Creating partitioned and clustered table fhv_trips_partitioned_clustered
CREATE OR REPLACE TABLE `ny-rides-shanu.dezoomcamp.fhv_trips_partitioned_clustered`
  PARTITION BY DATE(pickup_datetime)
  CLUSTER BY (Affiliated_base_number) AS
  SELECT * FROM `ny-rides-shanu.dezoomcamp.fhv_trips`;



-- Counting distinct number of affiliated_base_number on partitioned and clustered table
-- ~24 MB for the partitioned table
SELECT COUNT(DISTINCT Affiliated_base_number) FROM `ny-rides-shanu.dezoomcamp.fhv_trips_partitioned_clustered`
WHERE pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31';

-- Counting distinct number of affiliated_base_number on non-partitioned and non-clustered table
-- ~648 MB for the non-partitioned table
SELECT COUNT(DISTINCT Affiliated_base_number) FROM `ny-rides-shanu.dezoomcamp.fhv_trips`
WHERE pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31';