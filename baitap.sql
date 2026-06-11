--### 1. Lấy tất cả khách hàng. / Select all customers.

select *
from customers;


--### 2. Lấy tên và quốc gia của khách hàng. / Customer name and country only.

select name as customers_name , country
from customers;



--### 3. Khách hàng ở USA. / Customers from the USA.


select *
from customers 
where country= 'USA'

--### 4. Sản phẩm có giá > 200, sắp xếp giá giảm dần. / Products priced above 200, most expensive first.

select *
from products
where price > 200 
order by price desc


--### 5. Danh sách các quốc gia (không trùng). / Distinct list of countries.
SELECT  distinct country
from customers


-- ### 6. 5 sản phẩm đắt nhất. / Top 5 most expensive products.

select *
from products 
order by price desc
limit 5

select *
from products
where price in (select price
				from products 
				order by price desc
				limit 5)

--### 7. Đếm tổng số đơn hàng. / Count total orders.

select count (*) as total_orders
from orders;
				


--### 8. Đơn hàng có trạng thái 'completed' hoặc 'shipped'. / Orders that are completed or shipped.



select *
from orders
where status in ('completed', 'shipped')

-- ### 9. Khách hàng đăng ký trong năm 2022. / Customers who signed up in 2022.

select *
from customers
where year(signup_date) = 2022

select *
from customers 
where signup_date between  '2022-1-1' and  '2022-12-31'


--### 10. Giá trung bình, nhỏ nhất, lớn nhất của sản phẩm. / Avg, min, max product price.

select *
from products

select avg(price), min(price), max(price), 
from products

--### 11. Số sản phẩm theo từng danh mục. / Number of products per category.

select count (*) as Quantity, category
from products
group by category 
order by count(*) desc

-- ### 12. Danh mục có nhiều hơn 2 sản phẩm. / Categories with more than 2 products.

select count (*) as Quantity, category
from products
group by category 
having count (*)  >2
order by count(*) desc


--### 13. Khách có tên chứa chữ 'a' (không phân biệt hoa thường). / Customers whose name contains 'a'.

select *
from customers
where name like '%a%' or name like '%A%'


--### 14. Sản phẩm Electronics, sắp theo tên. / Electronics products, sorted by name.

select *
from products
where category  = 'Electronics' 
order by product_name

--### 15. Đơn hàng KHÔNG bị hủy. / Orders that are NOT cancelled.

select *
from orders
where status <>'cancelled'

--### 16. Mỗi đơn hàng kèm tên khách hàng. / Each order with the customer name (JOIN).

select ord.*, cust.name
from orders ord
left join customers cust 
	on ord.customer_id = cust.customer_id 


-- ### 17. Mỗi dòng đơn hàng kèm tên sản phẩm và thành tiền. / Each order line with product name and amount.

select *
from order_items

select *
from products

select order_id, product_name, price * quantity as amount
from order_items oit 
left join products pr on oit.product_id = pr.product_id

--### 18. Tổng doanh thu mỗi đơn hàng. / Total revenue per order.

select order_id, sum(price * quantity) as amount
from order_items oit 
left join products pr on oit.product_id = pr.product_id
group by order_id 


--### 18b.  Same using the mart.

select *
from fct_order_items;

select order_id, sum(line_revenue) as amount 
from fct_order_items
group by order_id ;

--### 19. Tất cả khách hàng kèm số đơn (kể cả khách 0 đơn). / All customers with order count, including those with none (LEFT JOIN).

select *
from orders

select *
from customers

select cust.customer_id, count (ord.order_id)
from customers cust
left join orders ord
	on cust.customer_id  = ord.customer_id 
group by cust.customer_id 

--### 20. Khách hàng chưa từng đặt đơn nào. / Customers who never placed an order.

select cst.name as customer_name, order_id 
from customers cst 
left join orders ord on cst.customer_id = ord.customer_id
where ord.order_id is null


--### 21. (Cách khác bằng NOT EXISTS) / Same with NOT EXISTS.

select *
from customers cst
where  not EXISTS (select 1  from orders ord where cst.customer_id = ord.customer_id )


select *
from customers 
where customer_id not in (select distinct customer_id from orders)


-- ### 22. Doanh thu theo quốc gia. / Revenue by customer country.

select *
from customers 

select *
from orders

select sum (line_revenue) as total_amount, country
from fct_order_items
group by country 


---

select *
from orders

select *
from order_items


select sum (quantity* price), country
from orders ord
left join order_items ordIte
	on ord.order_id = ordIte.order_id
left join customers cst  
	on cst.customer_id = ord.customer_id 
left join products prd 
	on ordIte.product_id = prd.product_id
group by country

--### 24. Số lượng bán ra của mỗi sản phẩm (kể cả SP chưa bán = 0). / Units sold per product, zero included.

select *
from order_items

select prd.product_id, coalesce(sum(quantity),0) as total_quantity
from products prd
left join order_items ordItem 
	on prd.product_id = ordItem.product_id
group by prd.product_id
order by total_quantity

--### 26. Sản phẩm có giá cao hơn giá trung bình toàn bộ. / Products priced above the overall average (subquery).

select *
from fct_order_items
where line_revenue >= (select avg(line_revenue)
						from fct_order_items )


--### 27. Năm–tháng của đơn hàng. / Extract year and month from order date.


select order_id, month(order_date), year(order_date)
from orders


--### 28. Doanh thu theo tháng. / Monthly revenue.


select month(order_date), sum(line_revenue)
from fct_order_items
group by month(order_date)
order by month(order_date)


--### 29. Số khách hàng theo từng quốc gia, chỉ nước có >= 2 khách. / Customers per country, only countries with 2+.


select count(*), country
FROM customers
group by country
having count(*)>2

--### 30. Nhân viên kèm tên phòng ban. / Employees with their department name.

select emp.name, dept.department_name
from employees emp
left join departments dept
	on emp.department_id = dept.department_id






























