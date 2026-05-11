with source as (

    select * from {{ source('saasify_raw', 'raw_accounts') }}

),

renamed as (

    select
        -- primary key
        account_id,

        -- dimensions
        account_name,
        plan_type,
        country,
        industry,

        -- numeric
        employee_count,

        -- timestamps
        cast(created_at as timestamp)   as created_at,

        -- categorisation helper
        case
            when plan_type = 'free'       then 0
            when plan_type = 'starter'    then 1
            when plan_type = 'pro'        then 2
            when plan_type = 'enterprise' then 3
            else -1
        end                             as plan_rank

    from source

)

select * from renamed