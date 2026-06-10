
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select department_id
from "practice"."main"."departments"
where department_id is null



  
  
      
    ) dbt_internal_test