
    
    

with all_values as (

    select
        category as value_field,
        count(*) as n_records

    from "practice"."main"."products"
    group by category

)

select *
from all_values
where value_field not in (
    'Electronics','Furniture','Appliances','Stationery'
)


