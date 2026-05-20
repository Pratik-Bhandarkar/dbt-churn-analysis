with account_health as (

    select * from {{ ref('fct_account_health') }}

),

final as (

    select
        -- primary key
        account_id,

        -- account identifiers
        account_name,
        plan_type,
        country,
        industry,

        -- financial context
        current_mrr_usd,
        effective_mrr_usd,

        -- health signals
        churn_score,
        expansion_score,
        ai_segment,
        active_user_ratio,
        days_since_last_event,
        is_active_last_30_days,
        total_events,
        active_user_count,
        feature_event_count,

        -- composite risk score
        -- weighted formula combining AI score with product signals
        -- weights: churn_score 50%, inactivity 30%, low usage 20%
        round(
            (churn_score * 0.50)
            +
            (case
                when days_since_last_event is null  then 0.30
                when days_since_last_event > 30     then 0.30
                when days_since_last_event > 14     then 0.15
                else                                     0.0
            end)
            +
            (case
                when active_user_ratio < 0.10       then 0.20
                when active_user_ratio < 0.25       then 0.10
                else                                     0.0
            end)
        , 4)                                        as composite_risk_score,

        -- recommended action for sales team
        case
            when churn_score >= 0.70
                or (churn_score >= 0.50
                    and days_since_last_event > 14)
            then 'urgent_outreach'

            when expansion_score >= 0.70
                and churn_score < 0.30
                and is_active_last_30_days = 1
            then 'expansion_opportunity'

            when churn_score >= 0.30
                and churn_score < 0.70
            then 'monitor_closely'

            else 'healthy_no_action'
        end                                         as recommended_action,

        -- ml feature flags (useful for model retraining)
        case when is_active_last_30_days = 1
            then true else false
        end                                         as feature_is_active,

        case when feature_event_count > 5
            then true else false
        end                                         as feature_is_power_user,

        case when current_mrr_usd > 299
            then true else false
        end                                         as feature_is_high_value,

        -- metadata
        scored_at,
        days_since_scored,
        current_timestamp                           as mart_updated_at

    from account_health

)

select * from final