with users as (

    select * from {{ ref('stg_users') }}

),

user_sessions as (

    select
        user_id,
        count(*)                        as total_sessions,
        sum(events_in_session)          as total_events,
        avg(session_duration_minutes)   as avg_session_duration_minutes,
        max(session_start_at)           as last_session_at,
        min(session_start_at)           as first_session_at

    from {{ ref('int_user_sessions') }}
    group by user_id

),

final as (

    select
        -- primary key
        u.user_id,

        -- foreign key
        u.account_id,

        -- user attributes
        u.email,
        u.role,
        u.created_at                            as user_created_at,
        u.last_login_at,
        u.days_since_last_login,

        -- engagement (macro-driven)
        u.engagement_tier,

        -- session metrics
        coalesce(s.total_sessions, 0)           as total_sessions,
        coalesce(s.total_events, 0)             as total_events,
        coalesce(
            s.avg_session_duration_minutes, 0)  as avg_session_duration_minutes,
        s.last_session_at,
        s.first_session_at,

        -- derived
        datediff('day',
            u.created_at,
            current_timestamp)                  as user_age_days,

        case
            when u.last_login_at >= current_timestamp - interval '7 days'
            then true else false
        end                                     as is_active_last_7_days

    from users as u
    left join user_sessions as s
        on u.user_id = s.user_id

)

select * from final