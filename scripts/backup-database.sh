#!/usr/bin/env bash
set -euo pipefail

: "${MSSQL_SA_PASSWORD:?MSSQL_SA_PASSWORD must be set}"

mkdir -p backups

docker exec transportation-sqlserver \
  /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b \
  -Q "BACKUP DATABASE TransportationDB TO DISK='/var/opt/mssql/backups/TransportationDB_full.bak' WITH INIT, COMPRESSION, CHECKSUM, STATS=10; RESTORE VERIFYONLY FROM DISK='/var/opt/mssql/backups/TransportationDB_full.bak' WITH CHECKSUM;"
