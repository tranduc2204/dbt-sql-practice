-- One row per order line, enriched with customer + product + revenue.
-- Bảng "phẳng" tiện cho việc luyện tập: join sẵn order + item + product + customer.
with items as (
    select * from "practice"."main"."stg_order_items"
),
orders as (
    select * from "practice"."main"."stg_orders"
),
products as (
    select * from "practice"."main"."stg_products"
),
customers as (
    select * from "practice"."main"."stg_customers"
)
select
    i.order_item_id,
    i.order_id,
    o.order_date,
    o.status,
    o.customer_id,
    c.customer_name,
    c.country,
    i.product_id,
    p.product_name,
    p.category,
    p.price,
    i.quantity,
    p.price * i.quantity as line_revenue
from items i
join orders    o on i.order_id    = o.order_id
join products  p on i.product_id  = p.product_id
join customers c on o.customer_id = c.customer_id