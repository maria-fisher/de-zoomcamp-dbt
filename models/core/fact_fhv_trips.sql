{{
    config(
        materialized='table'
    )
}}

with fhv_data_2019 as (
    select *, 
        'FHV' as service_type
    from {{ ref('stg_fhv_data_2019') }}
),  
 
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select fhv_data_2019.tripid,
    fhv_data_2019.dispatching_base_num, 
    fhv_data_2019.shared_ride_flag,
    fhv_data_2019.affiliated_base_number,    
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    fhv_data_2019.dropoff_location_id,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone 
  
from fhv_data_2019
inner join dim_zones as pickup_zone
on fhv_data_2019.pickup_location_id = pickup_zone.location_id
inner join dim_zones as dropoff_zone
on fhv_data_2019.dropoff_location_id = dropoff_zone.location_id