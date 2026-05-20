with accounts as (

    select * from {{ ref('stg_accounts') }}

),

account_activity as (

    select * from {{ ref('int_account_activity') }}

),

subscriptions as (

    select
        account_id,
        max(mrr_usd)                as current_mrr_usd,
        sum(mrr_change_usd)         as total_mrr_change_usd,
        count(*)                    as total_subscription_events,
        max(changed_at)             as last_subscription_change_at

    from {{ ref('stg_subscriptions') }}
    group by account_id

),

final as (

    select
        -- primary key
        a.account_id,

        -- account attributes
        a.account_name,
        a.plan_type,
        a.plan_rank,
        a.country,
        a.industry,
        a.employee_count,
        a.created_at                        as account_created_at,

        -- subscription metrics
        coalesce(s.current_mrr_usd, 0)      as current_mrr_usd,
        coalesce(s.total_mrr_change_usd, 0) as total_mrr_change_usd,
        coalesce(
            s.total_subscription_events, 0) as total_subscription_events,
        s.last_subscription_change_at,

        -- activity metrics (from intermediate)
        aa.total_events,
        aa.active_user_count,
        aa.feature_event_count,
        aa.reporting_usage_count,
        aa.api_usage_count,
        aa.export_usage_count,
        aa.is_active_last_30_days,
        aa.last_event_at,
        aa.days_since_last_event,

        -- derived account health indicators
        case
            when a.plan_type = 'free'
            then 0
            else coalesce(s.current_mrr_usd, 0)
        end                                 as effective_mrr_usd,

        datediff('day',
            a.created_at,
            current_timestamp)              as account_age_days

    from accounts as a
    left join account_activity as aa
        on a.account_id = aa.account_id
    left join subscriptions as s
        on a.account_id = s.account_id

)

select * from final