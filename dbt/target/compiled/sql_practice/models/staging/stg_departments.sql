with source as (
    select * from "practice"."main"."departments"
)
select
    department_id,
    department_name,
    location
from source