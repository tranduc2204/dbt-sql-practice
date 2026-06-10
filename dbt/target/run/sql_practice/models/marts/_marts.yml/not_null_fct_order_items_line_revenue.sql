
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select line_revenue
from "practice"."main"."fct_order_items"
where line_revenue is null



  
  
      
    ) dbt_internal_test