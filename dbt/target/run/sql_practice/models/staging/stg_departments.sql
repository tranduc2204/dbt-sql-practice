
  
  create view "practice"."main"."stg_departments__dbt_tmp" as (
    with source as (
    select * from "practice"."main"."departments"
)
select
    department_id,
    department_name,
    location
from source
  );
