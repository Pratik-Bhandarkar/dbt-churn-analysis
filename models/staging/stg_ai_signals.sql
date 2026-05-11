with source as (

    select * from {{ source('saasify_raw', 'raw_ai_signals') }}

),

renamed as (

    select
        -- primary key / foreign key
        account_id,

        -- scores — validated to be between 0 and 1
        case
            when churn_score < 0 then 0
            when churn_score > 1 then 1
            else churn_score
        end                         as churn_score,

        case
            when expansion_score < 0 then 0
            when expansion_score > 1 then 1
            else expansion_score
        end                         as expansion_score,

        -- dimensions
        ai_segment,

        -- timestamps
        cast(scored_at as timestamp) as scored_at

    from source

)

select * from renamed