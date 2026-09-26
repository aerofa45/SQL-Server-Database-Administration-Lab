#!/usr/bin/env bash
set -euo pipefail

: "${MSSQL_SA_PASSWORD:?MSSQL_SA_PASSWORD must be set}"

docker compose up -d

for i in {1..60}; do
  if docker exec transportation-sqlserver \
    /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
    -Q "SELECT 1" >/dev/null 2>&1; then
      break
  fi
  sleep 2
done

docker exec -e MSSQL_SA_PASSWORD="$MSSQL_SA_PASSWORD" transportation-sqlserver \
  bash /project/scripts/init-db.sh
