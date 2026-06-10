# 50 Câu hỏi SQL luyện tập / 50 SQL Practice Questions

> Dữ liệu nằm trong DuckDB (`warehouse/practice.duckdb`), schema `main`.
> Data lives in DuckDB, schema `main`.
>
> **Các bảng / Tables:**
> - Seeds (raw): `customers`, `products`, `orders`, `order_items`, `employees`, `departments`
> - Staging (view): `stg_customers`, `stg_orders`, `stg_order_items`, `stg_products`, `stg_employees`, `stg_departments`
> - Mart (table): `fct_order_items` (đã join sẵn order + product + customer + `line_revenue`)
>
> SQL viết theo chuẩn ANSI, chạy được trên **cả DuckDB và Trino**. Chỗ nào khác biệt sẽ có ghi chú.
> ANSI-style SQL that runs on **both DuckDB and Trino**; dialect differences are noted.

---

## A. Cơ bản / Basic (1–15)

### 1. Lấy tất cả khách hàng. / Select all customers.
```sql
SELECT * FROM customers;
```

### 2. Lấy tên và quốc gia của khách hàng. / Customer name and country only.
```sql
SELECT name, country FROM customers;
```

### 3. Khách hàng ở USA. / Customers from the USA.
```sql
SELECT name, city FROM customers WHERE country = 'USA';
```

### 4. Sản phẩm có giá > 200, sắp xếp giá giảm dần. / Products priced above 200, most expensive first.
```sql
SELECT product_name, price
FROM products
WHERE price > 200
ORDER BY price DESC;
```

### 5. Danh sách các quốc gia (không trùng). / Distinct list of countries.
```sql
SELECT DISTINCT country FROM customers ORDER BY country;
```

### 6. 5 sản phẩm đắt nhất. / Top 5 most expensive products.
```sql
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;
```

### 7. Đếm tổng số đơn hàng. / Count total orders.
```sql
SELECT COUNT(*) AS total_orders FROM orders;
```

### 8. Đơn hàng có trạng thái 'completed' hoặc 'shipped'. / Orders that are completed or shipped.
```sql
SELECT order_id, status
FROM orders
WHERE status IN ('completed', 'shipped');
```

### 9. Khách hàng đăng ký trong năm 2022. / Customers who signed up in 2022.
```sql
SELECT name, signup_date
FROM customers
WHERE signup_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31';
```

### 10. Giá trung bình, nhỏ nhất, lớn nhất của sản phẩm. / Avg, min, max product price.
```sql
SELECT
    AVG(price) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM products;
```

### 11. Số sản phẩm theo từng danh mục. / Number of products per category.
```sql
SELECT category, COUNT(*) AS n_products
FROM products
GROUP BY category
ORDER BY n_products DESC;
```

### 12. Danh mục có nhiều hơn 2 sản phẩm. / Categories with more than 2 products.
```sql
SELECT category, COUNT(*) AS n_products
FROM products
GROUP BY category
HAVING COUNT(*) > 2;
```

### 13. Khách có tên chứa chữ 'a' (không phân biệt hoa thường). / Customers whose name contains 'a'.
```sql
SELECT name FROM customers
WHERE LOWER(name) LIKE '%a%';
```

### 14. Sản phẩm Electronics, sắp theo tên. / Electronics products, sorted by name.
```sql
SELECT product_name, price
FROM products
WHERE category = 'Electronics'
ORDER BY product_name;
```

### 15. Đơn hàng KHÔNG bị hủy. / Orders that are NOT cancelled.
```sql
SELECT order_id, status
FROM orders
WHERE status <> 'cancelled';
```

---

## B. Trung cấp / Intermediate (16–35)

### 16. Mỗi đơn hàng kèm tên khách hàng. / Each order with the customer name (JOIN).
```sql
SELECT o.order_id, o.order_date, c.name AS customer_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
```

### 17. Mỗi dòng đơn hàng kèm tên sản phẩm và thành tiền. / Each order line with product name and amount.
```sql
SELECT oi.order_id, p.product_name, oi.quantity,
       p.price * oi.quantity AS line_amount
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;
```

### 18. Tổng doanh thu mỗi đơn hàng. / Total revenue per order.
```sql
SELECT oi.order_id, SUM(p.price * oi.quantity) AS order_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY oi.order_id
ORDER BY order_revenue DESC;
```

### 18b. (Cách ngắn với mart) / Same using the mart.
```sql
SELECT order_id, SUM(line_revenue) AS order_revenue
FROM fct_order_items
GROUP BY order_id;
```

### 19. Tất cả khách hàng kèm số đơn (kể cả khách 0 đơn). / All customers with order count, including those with none (LEFT JOIN).
```sql
SELECT c.name, COUNT(o.order_id) AS n_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name
ORDER BY n_orders;
```

### 20. Khách hàng chưa từng đặt đơn nào. / Customers who never placed an order.
```sql
SELECT c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

### 21. (Cách khác bằng NOT EXISTS) / Same with NOT EXISTS.
```sql
SELECT c.name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);
```

### 22. Doanh thu theo quốc gia. / Revenue by customer country.
```sql
SELECT f.country, SUM(f.line_revenue) AS revenue
FROM fct_order_items f
GROUP BY f.country
ORDER BY revenue DESC;
```

### 23. Doanh thu theo danh mục sản phẩm. / Revenue by product category.
```sql
SELECT category, SUM(line_revenue) AS revenue
FROM fct_order_items
GROUP BY category
ORDER BY revenue DESC;
```

### 24. Số lượng bán ra của mỗi sản phẩm (kể cả SP chưa bán = 0). / Units sold per product, zero included.
```sql
SELECT p.product_name, COALESCE(SUM(oi.quantity), 0) AS units_sold
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;
```

### 25. Phân loại đơn bằng CASE theo doanh thu. / Bucket orders by revenue using CASE.
```sql
SELECT order_id,
       SUM(line_revenue) AS revenue,
       CASE
           WHEN SUM(line_revenue) >= 1000 THEN 'High'
           WHEN SUM(line_revenue) >= 300  THEN 'Medium'
           ELSE 'Low'
       END AS revenue_band
FROM fct_order_items
GROUP BY order_id
ORDER BY revenue DESC;
```

### 26. Sản phẩm có giá cao hơn giá trung bình toàn bộ. / Products priced above the overall average (subquery).
```sql
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;
```

### 27. Năm–tháng của đơn hàng. / Extract year and month from order date.
```sql
SELECT order_id,
       EXTRACT(YEAR  FROM order_date) AS yr,
       EXTRACT(MONTH FROM order_date) AS mth
FROM orders;
```

### 28. Doanh thu theo tháng. / Monthly revenue.
```sql
SELECT date_trunc('month', order_date) AS month,
       SUM(line_revenue)               AS revenue
FROM fct_order_items
GROUP BY date_trunc('month', order_date)
ORDER BY month;
```

### 29. Số khách hàng theo từng quốc gia, chỉ nước có >= 2 khách. / Customers per country, only countries with 2+.
```sql
SELECT country, COUNT(*) AS n_customers
FROM customers
GROUP BY country
HAVING COUNT(*) >= 2;
```

### 30. Nhân viên kèm tên phòng ban. / Employees with their department name.
```sql
SELECT e.name, d.department_name, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id;
```

### 31. Nhân viên kèm tên quản lý (self-join). / Employee with their manager's name.
```sql
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY manager NULLS FIRST;
```

### 32. Lương trung bình theo phòng ban. / Average salary per department.
```sql
SELECT d.department_name, ROUND(AVG(e.salary), 0) AS avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC;
```

### 33. Khách hàng USA và đơn hàng của họ (gộp UNION minh họa). / Combine two queries with UNION.
```sql
SELECT name AS person, 'customer' AS type FROM customers WHERE country = 'USA'
UNION ALL
SELECT name, 'employee' FROM employees;
```

### 34. Đơn hàng có TỪ 2 sản phẩm khác nhau trở lên. / Orders containing 2+ distinct products.
```sql
SELECT order_id, COUNT(DISTINCT product_id) AS distinct_products
FROM order_items
GROUP BY order_id
HAVING COUNT(DISTINCT product_id) >= 2;
```

### 35. Khách hàng đã mua sản phẩm 'Laptop'. / Customers who bought a 'Laptop'.
```sql
SELECT DISTINCT f.customer_name
FROM fct_order_items f
WHERE f.product_name = 'Laptop';
```

---

## C. Nâng cao / Advanced (36–50)

### 36. Xếp hạng sản phẩm theo doanh thu (window). / Rank products by revenue.
```sql
SELECT product_name,
       SUM(line_revenue) AS revenue,
       RANK() OVER (ORDER BY SUM(line_revenue) DESC) AS revenue_rank
FROM fct_order_items
GROUP BY product_name
ORDER BY revenue_rank;
```

### 37. Đánh số dòng đơn trong mỗi đơn hàng. / Number the lines within each order (ROW_NUMBER).
```sql
SELECT order_id, product_name, quantity,
       ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY line_revenue DESC) AS rn
FROM fct_order_items;
```

### 38. Sản phẩm bán chạy nhất trong MỖI danh mục (top-1 per group). / Best-selling product per category.
```sql
WITH p AS (
    SELECT category, product_name,
           SUM(quantity) AS units,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(quantity) DESC) AS rn
    FROM fct_order_items
    GROUP BY category, product_name
)
SELECT category, product_name, units
FROM p
WHERE rn = 1;
```
> DuckDB & Trino hỗ trợ `QUALIFY` để viết gọn:
> ```sql
> SELECT category, product_name, SUM(quantity) AS units
> FROM fct_order_items
> GROUP BY category, product_name
> QUALIFY ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(quantity) DESC) = 1;
> ```

### 39. Doanh thu lũy kế theo tháng (running total). / Running monthly revenue.
```sql
WITH monthly AS (
    SELECT date_trunc('month', order_date) AS month,
           SUM(line_revenue)               AS revenue
    FROM fct_order_items
    GROUP BY date_trunc('month', order_date)
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM monthly
ORDER BY month;
```

### 40. So sánh doanh thu tháng này với tháng trước (LAG). / Month-over-month comparison.
```sql
WITH monthly AS (
    SELECT date_trunc('month', order_date) AS month,
           SUM(line_revenue)               AS revenue
    FROM fct_order_items
    GROUP BY date_trunc('month', order_date)
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month)                       AS prev_revenue,
       revenue - LAG(revenue) OVER (ORDER BY month)             AS mom_change
FROM monthly
ORDER BY month;
```

### 41. % doanh thu của mỗi danh mục trên tổng. / Each category's share of total revenue.
```sql
SELECT category,
       SUM(line_revenue) AS revenue,
       ROUND(100.0 * SUM(line_revenue)
             / SUM(SUM(line_revenue)) OVER (), 2) AS pct_of_total
FROM fct_order_items
GROUP BY category
ORDER BY revenue DESC;
```

### 42. Lương cao thứ 2 trong mỗi phòng ban (DENSE_RANK). / 2nd-highest salary per department.
```sql
WITH ranked AS (
    SELECT name, department_id, salary,
           DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT name, department_id, salary
FROM ranked
WHERE rnk = 2;
```

### 43. Top 3 khách hàng chi tiêu nhiều nhất. / Top 3 spending customers.
```sql
SELECT customer_name, SUM(line_revenue) AS total_spent
FROM fct_order_items
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 3;
```

### 44. Chia khách hàng thành 4 nhóm chi tiêu (NTILE). / Split customers into 4 spending quartiles.
```sql
SELECT customer_name,
       SUM(line_revenue) AS total_spent,
       NTILE(4) OVER (ORDER BY SUM(line_revenue) DESC) AS spend_quartile
FROM fct_order_items
GROUP BY customer_name;
```

### 45. Cây phân cấp nhân viên (recursive CTE). / Employee hierarchy with levels.
```sql
WITH RECURSIVE hierarchy AS (
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.name, e.manager_id, h.level + 1
    FROM employees e
    JOIN hierarchy h ON e.manager_id = h.employee_id
)
SELECT level, employee_id, name
FROM hierarchy
ORDER BY level, employee_id;
```

### 46. Giá trị đơn trung bình (AOV) theo quốc gia. / Average order value per country.
```sql
WITH order_totals AS (
    SELECT order_id, country, SUM(line_revenue) AS order_total
    FROM fct_order_items
    GROUP BY order_id, country
)
SELECT country,
       COUNT(*)              AS n_orders,
       ROUND(AVG(order_total), 2) AS avg_order_value
FROM order_totals
GROUP BY country
ORDER BY avg_order_value DESC;
```

### 47. Trung vị giá sản phẩm (percentile). / Median product price.
```sql
-- ANSI / Trino & DuckDB:
SELECT approx_percentile(price, 0.5) AS median_price FROM products;
-- Chính xác (cả hai đều hỗ trợ) / exact:
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS median_price FROM products;
```

### 48. Pivot: doanh thu theo quốc gia × năm. / Pivot revenue by country and year.
```sql
SELECT country,
       SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2022 THEN line_revenue ELSE 0 END) AS rev_2022,
       SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2023 THEN line_revenue ELSE 0 END) AS rev_2023
FROM fct_order_items
GROUP BY country
ORDER BY country;
```

### 49. Khách hàng chi tiêu trên mức trung bình (correlated / CTE). / Customers spending above the average customer.
```sql
WITH per_customer AS (
    SELECT customer_name, SUM(line_revenue) AS total_spent
    FROM fct_order_items
    GROUP BY customer_name
)
SELECT customer_name, total_spent
FROM per_customer
WHERE total_spent > (SELECT AVG(total_spent) FROM per_customer)
ORDER BY total_spent DESC;
```

### 50. Tỷ lệ hủy đơn theo quốc gia. / Order cancellation rate per country.
```sql
SELECT c.country,
       COUNT(*)                                                              AS total_orders,
       SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END)               AS cancelled_orders,
       ROUND(100.0 * SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END)
             / COUNT(*), 1)                                                  AS cancel_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY cancel_rate_pct DESC;
```

---

## Ghi chú khác biệt DuckDB vs Trino / Dialect notes

| Chủ đề | DuckDB | Trino |
|---|---|---|
| Nối chuỗi / concat | `||` hoặc `concat()` | `||` hoặc `concat()` |
| Ép kiểu ngày / date literal | `DATE '2022-01-01'` | `DATE '2022-01-01'` |
| `QUALIFY` | ✅ | ✅ |
| Trung vị / median | `percentile_cont`, `approx_percentile` | `approx_percentile`, `percentile_cont` (WITHIN GROUP) |
| `date_trunc` | `date_trunc('month', d)` | `date_trunc('month', d)` |
| `LIMIT` | ✅ | ✅ (cũng có `FETCH FIRST n ROWS`) |

Tất cả 50 câu trên dùng cú pháp ANSI nên chạy được trên cả hai engine.
All 50 answers use ANSI syntax and run on both engines.
