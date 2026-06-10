with source as (
    select * from {{ ref('departments') }}
)
select
    department_id,
    department_name,
    location
from source
