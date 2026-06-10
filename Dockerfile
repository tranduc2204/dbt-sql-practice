FROM python:3.11-slim

# dbt + DuckDB adapter
RUN pip install --no-cache-dir \
    dbt-core==1.8.* \
    dbt-duckdb==1.8.* \
    duckdb==1.* \
    && rm -rf /root/.cache

WORKDIR /usr/app/dbt

# dbt looks for profiles.yml here
ENV DBT_PROFILES_DIR=/usr/app/dbt

# A place to store the duckdb file (mounted as a volume in compose)
RUN mkdir -p /usr/app/warehouse

# Keep the container alive so you can `docker compose exec` into it
CMD ["tail", "-f", "/dev/null"]
