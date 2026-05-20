with accounts as (

    select * from {{ ref('dim_accounts') }}

),

ai_signals as (

    select * from {{ ref('stg_ai_signals') }}

),

final as (

    select
        -- primary key
        a.account_id,

        -- account context
        a.account_name,
        a.plan_type,
        a.plan_rank,
        a.country,
        a.industry,
        a.employee_count,
        a.account_age_days,

        -- financial signals
        a.current_mrr_usd,
        a.effective_mrr_usd,
        a.total_mrr_change_usd,

        -- product usage signals
        a.total_events,
        a.active_user_count,
        a.feature_event_count,
        a.reporting_usage_count,
        a.api_usage_count,
        a.export_usage_count,
        a.is_active_last_30_days,
        a.days_since_last_event,

        -- ai signals
        ai.churn_score,
        ai.expansion_score,
        ai.ai_segment,
        ai.scored_at,

        -- derived health metrics
        case
            when a.active_user_count = 0 then 0
            else round(
                a.active_user_count * 1.0 /
                nullif(a.employee_count, 0), 4
            )
        end                                     as active_user_ratio,

        datediff('day',
            ai.scored_at,
            current_timestamp)                  as days_since_scored

    from accounts as a
    left join ai_signals as ai
        on a.account_id = ai.account_id

)

select * from final