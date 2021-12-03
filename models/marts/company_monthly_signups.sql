select 
    DATE_TRUNC(DATE(user_signuped_time), MONTH) as signup_month,
    c.company_id,
    case when count(distinct u.user_id) < 10 then 'C'
        when count(distinct u.user_id) < 50 then 'B'
        else 'A' end as company_tier,
    count(distinct u.user_id) as signups_count
from {{ ref('stg_company') }} c
join {{ ref('stg_users') }} u on u.company_id = c.company_id -- dont' need left join because u.company_id cannot be null
group by signup_month, company_id
order by company_id, signup_month

-- tests
-- user_signuped_time > c.created_at
-- members_count > 0
-- company_tier in A, B, C