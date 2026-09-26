# Windows setup and verified results

Verified on 2026-09-25 (America/Chicago).

## Start and connect

From the project folder, run `docker compose up -d` and wait until the SQL Server log says it is ready for client connections.

In SQL Server Management Studio use:

- Server: `localhost,1433`
- Authentication: SQL Server Authentication
- Login: `sa`
- Password: your existing value in `.env`
- Encryption: Mandatory
- Trust server certificate: enabled for this local lab
- Database: `TransportationDB`

An encrypted Windows TCP connection using this project's password was verified successfully. The password has not been changed or included in this repository.

For a NEW database only, initialize using:

```powershell
docker exec transportation-sqlserver bash /project/scripts/init-db.sh
```

The container already receives the password from Compose; no manual password entry into the terminal is needed. Do not rerun initialization on data you want to preserve: `02_schema.sql` drops and rebuilds the project tables.

## Completed checks

- Primary and recovery-test databases ONLINE, SIMPLE recovery.
- 11 road assets (5 seeded plus 6 imported), 4 work orders.
- 3 views and 3 stored procedures created.
- Security roles and memberships created; analyst read access and denied update access verified; operations update access and denied database control verified; DBA database control verified.
- Index creation, query statistics, monitoring queries and priority migration executed.
- Full compressed backup with checksum created, verified and restored.
- DBCC CHECKDB passed for primary and restored databases.
- Matching asset and work-order counts in restored database.

The original security script contained invalid `GRANT CONTROL DATABASE` syntax. It is corrected to `GRANT CONTROL ON DATABASE::TransportationDB TO DBA_Admin`.

See `VERIFICATION_RESULTS.txt` and repeat the read-only checks with `sql/11_verify.sql` in SSMS.

## Screenshots to capture in SSMS

1. Object Explorer expanded to the tables, views and procedures.
2. `SELECT * FROM TransportationDB.dbo.RoadAsset;`
3. Role membership output from `sql/04_security.sql` (the final SELECT).
4. Enable Actual Execution Plan and run the operational SELECT in `sql/07_performance_tuning.sql`.
5. Both databases in Object Explorer and restored row counts from `sql/11_verify.sql`.

Screenshots are not yet captured. The tiny sample dataset demonstrates the tuning workflow; it does not establish a production-scale speed improvement.

The local backup is in `backups/TransportationDB_full.bak`. Backups and `.env` are excluded from Git.
`nThe monitoring script also used SELECT aliases inside an ORDER BY expression; this was corrected to use the underlying index-usage columns. All monitoring batches passed after correction.
