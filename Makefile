connections.duckdb: generate.sql
	duckdb connections.duckdb < generate.sql

.PHONY: test
test:
	make && uv run pytest -v