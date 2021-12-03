-- dbt_util package installed in "packages.yml" - Run dbt deps to install the package.
{%- set user_events = dbt_utils.get_column_values(
    table=ref('stg_user_event'),
    column='event_name'
) -%}

{{ config(
    schema='events'
) }}

select
user_id,
{%- for user_event in user_events %}. -- for each user_event, create two columns:
count(distinct case when event_name = '{{user_event}}' then event_datetime end) as {{user_event}}_count,
max(case when event_name = '{{user_event}}' then DATE(event_datetime) end) as {{user_event}}_last_date
{%- if not loop.last %},{% endif -%}
{% endfor %}
from {{ ref('stg_user_event') }}
where DATE(event_datetime) >= DATE_ADD(CURRENT_DATE(), INTERVAL -30 DAY)
group by user_id