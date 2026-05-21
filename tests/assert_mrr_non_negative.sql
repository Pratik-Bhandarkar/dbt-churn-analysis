-- Singular test: assert that MRR values are never negative
-- A negative MRR value in fct_subscriptions would indicate a data error
-- because mrr_usd represents the NEW MRR amount after a change,
-- not the change itself (mrr_change_usd handles signed values)
--
-- This test returns rows that VIOLATE the assertion.
-- Zero rows returned = test passes.
-- Any rows returned = test fails.

select
    subscription_id,
    account_id,
    mrr_usd,
    change_reason

from {{ ref('fct_subscriptions') }}

where mrr_usd < 0