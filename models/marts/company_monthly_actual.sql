select 
    c.month_,
    c.company_id,
    case when s.signups_count - ch.churn_count < 10 then 'C'
        when s.signups_count - ch.churn_count < 50 then 'B'
        else 'A' end as company_tier,
    s.signups_count - ch.churn_count as actual_members_count
from 
( -- this is a calendar by company_id
    select distinct company_id, month_
    from {{ ref('stg_company') }} c
    cross join 
    (
    SELECT
    DATE_TRUNC(date_generator, MONTH) as month_,
    FROM 
        UNNEST(GENERATE_DATE_ARRAY(
    --     '2018-10-01', 
            (select min(DATE(created_at)) from {{ ref('stg_company') }}),
            current_date(), 
            INTERVAL 1 Month)) AS date_generator
    ) cal
    where cal.month_ >= DATE_TRUNC(DATE(c.created_at), MONTH) -- exclude months bellow month of creation
    order by company_id, month_
) c
left join {{ ref('company_monthly_signups') }} s on s.signup_month = c.month_
left join {{ ref('company_monthly_churns') }} ch on ch.company_id = s.company_id
and ch.churn_month = c.month_