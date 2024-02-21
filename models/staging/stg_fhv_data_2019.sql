{{ 
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *,
    -- Remove the deduplication step by removing the row_number() function
  from {{ source('staging','fhv_data_2019') }}
  where dispatching_base_num is not null 
)
select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
    {{ dbt.safe_cast("dispatching_base_num", api.Column.translate_type("text")) }} as dispatching_base_num,
    {{ dbt.safe_cast("affiliated_base_number", api.Column.translate_type("text")) }} as affiliated_base_number,
    {{ dbt.safe_cast("shared_ride_flag", api.Column.translate_type("text")) }} as shared_ride_flag,
    {{ dbt.safe_cast("pickup_location_id", api.Column.translate_type("integer")) }} as pickup_location_id,
    {{ dbt.safe_cast("dropoff_location_id", api.Column.translate_type("integer")) }} as dropoff_location_id,
    
   
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    
 
from tripdata

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=false) %}

  limit 100

{% endif %}