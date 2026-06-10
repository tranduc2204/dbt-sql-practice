with source as (
    select * from {{ ref('customers') }}
)
select
    customer_id,
    name        as customer_name,
    country,
    city,
    cast(signup_date as date) as signup_date
from source
