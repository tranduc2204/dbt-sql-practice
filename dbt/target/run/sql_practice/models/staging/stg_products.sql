
  
  create view "practice"."main"."stg_products__dbt_tmp" as (
    with source as (
    select * from "practice"."main"."products"
)
select
    product_id,
    product_name,
    category,
    cast(price as decimal(10,2)) as price
from source
  );
