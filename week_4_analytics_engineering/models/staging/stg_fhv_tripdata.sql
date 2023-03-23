{{ config(materialized="view") }}
select
    int64_field_0 as fhvid,
    dispatching_base_num as dispatching_base_number,
    pickup_datetime as pickup_datetime,
    dropOff_datetime as dropoff_datetime,
    PUlocationID as pickup_locationid,
    DOlocationID as dropoff_locationid,
    SR_Flag as sr_flag,
    Affiliated_base_number as affiliated_base_number
from {{ source("staging", "fhv_trips_partitioned_clustered") }}

--with
--    tripdata as (
--        select *
--        from {{ source("staging", "fhv_trips_partitioned_clustered") }}
--        where int64_field_0 is not null
--    )
--select
--    int64_field_0 as tripid,
--    dispatching_base_num as dispatching_base_number,
--    cast(pickup_datetime as timestamp) as pickup_datetime,
--    cast(dropOff_datetime as timestamp) as dropoff_datetime,
--    cast(PUlocationID as numeric) as pickup_locationid,
--    cast(DOlocationID as numeric) as dropoff_locationid,
--    SR_Flag as store_and_fwd_flag,
--    Affiliated_base_number as Affiliated_base_number
--from tripdata
