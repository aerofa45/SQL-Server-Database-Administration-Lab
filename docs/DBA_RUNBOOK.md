# DBA Runbook

## System
- Platform: Microsoft SQL Server 2022 Developer
- Primary database: `TransportationDB`
- Recovery model: SIMPLE
- Container: `transportation-sqlserver`

## Daily Checks

### Database State
```sql
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name = 'TransportationDB';
```

### Active Requests
Run `sql/06_monitoring.sql` and inspect:
- long-running sessions
- blocking
- excessive reads
- abnormal waits

### Backup Verification
Verify that the most recent `.bak` file exists and run:
```sql
RESTORE VERIFYONLY
FROM DISK='/var/opt/mssql/backups/TransportationDB_full.bak'
WITH CHECKSUM;
```

## Weekly Maintenance

Run:
```sql
DBCC CHECKDB ('TransportationDB') WITH NO_INFOMSGS;
EXEC TransportationDB.sys.sp_updatestats;
```

Review:
- index fragmentation
- index usage
- expensive queries
- database size growth
- failed or blocked requests

## User Access Review

```sql
USE TransportationDB;

SELECT
    member.name AS UserName,
    role.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals role
  ON drm.role_principal_id = role.principal_id
JOIN sys.database_principals member
  ON drm.member_principal_id = member.principal_id
ORDER BY role.name, member.name;
```

Expected roles:
- `DBA_Admin`
- `DataAnalyst`
- `OperationsUser`

Access should follow least privilege.

## Troubleshooting Checklist

### Application cannot connect
1. Confirm SQL Server container is running.
2. Confirm port 1433 is published.
3. Confirm credentials.
4. Confirm database state is ONLINE.
5. Review firewall/network settings.
6. Review SQL Server logs.

### Query is slow
1. Capture the query and execution plan.
2. Check logical reads and elapsed time.
3. Review indexes.
4. Review blocking.
5. Review stale statistics.
6. Check row count and predicate selectivity.

### Database integrity concern
1. Stop destructive operations.
2. Run `DBCC CHECKDB`.
3. Review SQL Server error logs.
4. Preserve a current backup.
5. Restore into an isolated recovery database if validation is required.

### Accidental data change
1. Preserve the current database state.
2. Identify the affected table and time window.
3. Restore the latest valid backup to a separate database.
4. Validate recovered data.
5. Copy required rows back using a controlled transaction.
6. Document the incident and recovery.
