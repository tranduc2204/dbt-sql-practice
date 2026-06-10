with source as (
    select * from "practice"."main"."order_items"
)
select
    order_item_id,
    order_id,
    product_id,
    quantity
from source