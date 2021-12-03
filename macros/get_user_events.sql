{% macro get_user_events() %}

{% set user_events_query %}
select distinct
event_name
from {{ ref('stg_user_event') }}
order by 1
{% endset %}

{% set results = run_query(user_events_query) %}

{% if execute %}
{# Return the first column #}
{% set results_list = results.columns[0].values() %}
{% else %}
{% set results_list = [] %}
{% endif %}

{{ return(results_list) }}

{% endmacro %}