# Backup and Recovery Plan

## Objectives

The project demonstrates a basic recovery workflow for an operational SQL Server database.

## Backup Type

A full database backup is written to:

`/var/opt/mssql/backups/TransportationDB_full.bak`

The backup uses:
- CHECKSUM
- COMPRESSION
- INIT
- progress statistics

## Backup Validation

Every backup workflow includes:

```sql
RESTORE VERIFYONLY
FROM DISK='/var/opt/mssql/backups/TransportationDB_full.bak'
WITH CHECKSUM;
```

This verifies that SQL Server can read the backup structure and checksum information.

## Recovery Test

The backup is restored into a separate database:

`TransportationDB_RecoveryTest`

Testing recovery separately prevents the production database from being overwritten during a routine validation exercise.

## Recovery Validation

After restore:
1. Verify database is ONLINE.
2. Run `DBCC CHECKDB`.
3. Validate row counts.
4. Inspect critical tables.
5. Confirm stored procedures and views exist.
6. Record the outcome.

## Example Validation Queries

```sql
SELECT COUNT(*) AS RoadAssets FROM TransportationDB_RecoveryTest.dbo.RoadAsset;
SELECT COUNT(*) AS WorkOrders FROM TransportationDB_RecoveryTest.dbo.WorkOrder;
DBCC CHECKDB ('TransportationDB_RecoveryTest') WITH NO_INFOMSGS;
```

## Production Considerations

A production environment would normally add:
- scheduled backups
- encrypted backup storage
- off-host or off-site copies
- retention rules
- alerting
- recovery-point and recovery-time objectives
- periodic restore drills
- FULL recovery model and transaction-log backups where point-in-time recovery is required
