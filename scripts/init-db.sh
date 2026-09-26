#!/usr/bin/env bash
set -euo pipefail

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
SERVER="localhost"
USER="sa"

for i in {1..60}; do
  if "$SQLCMD" -S "$SERVER" -U "$USER" -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

for file in /project/sql/01_create_database.sql \
            /project/sql/02_schema.sql \
            /project/sql/03_seed_data.sql \
            /project/sql/04_security.sql \
            /project/sql/05_import_export.sql \
            /project/sql/07_performance_tuning.sql \
            /project/sql/09_integrity_maintenance.sql \
            /project/sql/10_schema_migration.sql
do
  echo "Running $file"
  "$SQLCMD" -S "$SERVER" -U "$USER" -P "$MSSQL_SA_PASSWORD" -C -b -i "$file"
done

echo "Database initialization completed."
