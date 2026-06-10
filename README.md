# dbt + DuckDB — SQL Practice Project

Project luyện SQL từ cơ bản đến nâng cao, build & chạy hoàn toàn bằng Docker.
A SQL-practice project (basic → advanced), fully containerized with Docker. Warehouse = **DuckDB**.

## Cấu trúc / Structure
```
dbt-sql-practice/
├── docker-compose.yml
├── Dockerfile
├── QUESTIONS.md          # 50 câu hỏi + đáp án (song ngữ)
└── dbt/
    ├── dbt_project.yml
    ├── profiles.yml
    ├── packages.yml
    ├── seeds/            # dữ liệu CSV + _seeds.yml (tests)
    └── models/
        ├── staging/      # stg_* + _staging.yml
        └── marts/        # fct_order_items + _marts.yml
```

## Chạy / Run

```bash
cd dbt-sql-practice

# 1) Build image + chạy seed/run/test, rồi container ở lại để query
docker compose up --build
```
Lệnh trên sẽ tự động: `dbt deps` → `dbt seed` → `dbt run` → `dbt test`.

## Truy vấn dữ liệu / Query the data

Mở 1 terminal khác, vào trong container và dùng DuckDB CLI:
```bash
docker compose exec dbt python -c "import duckdb; \
  con=duckdb.connect('/usr/app/warehouse/practice.duckdb'); \
  print(con.sql('SELECT country, SUM(line_revenue) rev FROM fct_order_items GROUP BY 1 ORDER BY 2 DESC').df())"
```

Hoặc chạy lệnh dbt thủ công bên trong container:
```bash
docker compose exec dbt bash
dbt seed     # nạp lại CSV
dbt run      # build models
dbt test     # chạy data tests
dbt docs generate && dbt docs serve --port 8080   # xem tài liệu
```

## Bảng có sẵn / Available tables (schema `main`)
- Raw: `customers`, `products`, `orders`, `order_items`, `employees`, `departments`
- Staging: `stg_*`
- Mart: `fct_order_items`

Xem **QUESTIONS.md** để bắt đầu luyện tập. / See **QUESTIONS.md** to start practicing.

## Về Trino / About Trino — đọc kỹ
Xem ghi chú trong câu trả lời / phần cuối QUESTIONS.md: SQL viết theo chuẩn ANSI nên
copy chạy được trên cả Trino lẫn DuckDB. Trino **không** đọc trực tiếp file `.duckdb` bằng
connector chính thức, nên nếu muốn engine Trino thật sự, cần kiến trúc khác (xem chat).
