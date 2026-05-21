{% snapshot snp_account_plans %}

{{
    config(
        target_schema='snapshots',
        unique_key='account_id',
        strategy='check',
        check_cols=['plan_type', 'employee_count']
    )
}}

select
    account_id,
    account_name,
    plan_type,
    plan_rank,
    country,
    industry,
    employee_count,
    created_at

from {{ ref('stg_accounts') }}

{% endsnapshot %}