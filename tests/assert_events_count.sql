-- Number of events are a positive number, so the total events should always be >= 1.
-- Therefore return records where this isn't true to make the test fail
select
    user_id, sum(count_) as sum_
from
(
    select
        user_id, count(*) as count_ -- because we don't know the events
    from {{ ref('user_event_last_30_days' )}}
    group by user_id
)
group by user_id
having not(sum_ >= 1)