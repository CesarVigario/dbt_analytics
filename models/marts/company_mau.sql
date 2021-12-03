{{ 
    config(
        partition_by = {
        'field': 'activity_month',
        'data_type': 'date',
        'granularity': 'month'
        },
        cluster_by = 'company_id',
        schema = 'reporting'
    ) 
}}

select 
    --FORMAT_DATE('%YM%m', event_datetime) as activity_month_string,
    DATE_TRUNC(DATE(event_datetime), MONTH) as activity_month, -- we might need to right join a calendar, for months with no user activity
    c.company_id,
    case when count(distinct u.user_id) < 10 then 'C'
        when count(distinct u.user_id) < 50 then 'B'
        else 'A' end as company_tier,
    count(distinct u.user_id) as members_count
from {{ ref('stg_company') }} c
join {{ ref('stg_users') }} u on u.company_id = c.company_id -- dont' need left join because u.company_id cannot be null
join {{ ref('stg_user_event') }} e on e.id_user = u.id_user
group by activity_month, company_id
order by company_id, activity_month