with source as (

    select * from {{ source('saasify_raw', 'raw_users') }}

),

renamed as (

    select
        -- primary key
        user_id,

        -- foreign keys
        account_id,

        -- dimensions
        email,
        role,

        -- timestamps
        cast(created_at as timestamp)       as created_at,
        cast(last_login_at as timestamp)    as last_login_at,

        -- booleans
        is_deleted,

        -- derived
        datediff('day', 
            cast(last_login_at as timestamp), 
            current_timestamp)              as days_since_last_login,
        {{ classify_engagement(
            "datediff('day', cast(last_login_at as timestamp), current_timestamp)"
        ) }} as engagement_tier

    from source

    -- filter out deleted users at the staging layer
    -- downstream models never need to worry about this
    where is_deleted = false

)

select * from renamed