with source as (

    select * from {{ source('saasify_raw', 'raw_events') }}

),

renamed as (

    select
        -- primary key
        event_id,

        -- foreign keys
        user_id,
        account_id,

        -- dimensions
        event_type,

        -- timestamps
        cast(event_at as timestamp)     as event_at,

        -- json parsing
        -- extract the most useful properties fields
        json_extract_string(
            properties, '$.page')       as event_page,
        json_extract_string(
            properties, '$.feature')    as event_feature,

        -- keep raw properties for flexibility
        properties                      as raw_properties

    from source

)

select * from renamed