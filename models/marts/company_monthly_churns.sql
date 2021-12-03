{{ 
    config(
        partition_by = {
        'field': 'churn_month',
        'data_type': 'date',
        'granularity': 'month'
        },
        cluster_by = 'company_id',
        schema = 'reporting'
    ) 
}}

select 
    DATE_TRUNC(DATE(user_leaved_time), MONTH) as churn_month,
    c.company_id,
    case when count(distinct u.user_id) < 10 then 'C'
        when count(distinct u.user_id) < 50 then 'B'
        else 'A' end as company_tier,
    count(distinct u.user_id) as churn_count,
from {{ ref('stg_company') }} c
join {{ ref('stg_users') }} u on u.company_id = c.company_id -- dont' need left join because u.company_id cannot be null
group by signup_month, company_id
order by company_id, signup_month