
  
  create view "practice"."main"."stg_customers__dbt_tmp" as (
    with source as (
    select * from "practice"."main"."customers"
)
select
    customer_id,
    name        as customer_name,
    country,
    city,
    cast(signup_date as date) as signup_date
from source
  );
