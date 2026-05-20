with source as (

    select * from {{ source('saasify_raw', 'raw_subscriptions') }}

),

renamed as (

    select
        -- primary key
        subscription_id,

        -- foreign keys
        account_id,

        -- dimensions
        plan_from,
        plan_to,
        change_reason,

        -- numeric
        mrr_usd,
        {{ cents_to_dollars('mrr_usd') }}   as mrr_dollars,
        -- derived
        case
            when change_reason = 'upgrade'   then mrr_usd
            when change_reason = 'downgrade' then -mrr_usd
            when change_reason = 'churn'     then -mrr_usd
            else 0
        end                                  as mrr_change_usd,

        -- timestamps
        cast(changed_at as timestamp)        as changed_at

    from source

)

select * from renamed