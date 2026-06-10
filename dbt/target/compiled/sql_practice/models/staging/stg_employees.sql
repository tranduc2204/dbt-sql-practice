with source as (
    select * from "practice"."main"."employees"
)
select
    employee_id,
    name as employee_name,
    department_id,
    manager_id,
    cast(salary as decimal(12,2)) as salary,
    cast(hire_date as date)       as hire_date
from source