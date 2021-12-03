select
    *
from {{ source('gitbookexercise','user_event') }}