# Missouri Transportation Database Administration Lab

A portfolio-scale SQL Server database administration project that simulates an enterprise transportation asset and maintenance system.

The project demonstrates practical DBA work in:

- SQL Server installation and containerized deployment
- relational schema design
- T-SQL scripting
- database users, roles, permissions, and least-privilege access
- data import and export
- backup and restore
- database integrity checks
- activity and performance monitoring
- indexing and query tuning
- schema migration
- operational documentation and recovery procedures

## Project Scenario

A transportation agency needs a database to track:

- road assets
- inspection records
- maintenance work orders
- employees
- maintenance crews
- asset status and condition

The database must support analysts, operations staff, and administrators while protecting administrative functions through role-based access control.

## Architecture

```text
                    +----------------------+
                    |     SQL Server       |
                    |  TransportationDB    |
                    +----------+-----------+
                               |
          +--------------------+--------------------+
          |                    |                    |
   +------v------+      +------v------+      +------v------+
   | DBA_Admin   |      | DataAnalyst |      | Operations  |
   | Full Admin  |      | Read Access |      | Work Orders |
   +-------------+      +-------------+      +-------------+

Data Sources
    |
    +--> CSV road asset import
    +--> T-SQL seed data
    +--> Maintenance/inspection transactions

Administration
    |
    +--> Backup / Restore
    +--> DBCC CHECKDB
    +--> Query monitoring
    +--> Index maintenance
    +--> Schema migrations
```

## Repository Structure

```text
modot_sqlserver_dba_project/
├── README.md
├── docker-compose.yml
├── .env.example
├── .gitignore
├── data/
│   └── road_assets_import.csv
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_schema.sql
│   ├── 03_seed_data.sql
│   ├── 04_security.sql
│   ├── 05_import_export.sql
│   ├── 06_monitoring.sql
│   ├── 07_performance_tuning.sql
│   ├── 08_backup_restore.sql
│   ├── 09_integrity_maintenance.sql
│   └── 10_schema_migration.sql
├── scripts/
│   ├── init-db.sh
│   ├── run-all.sh
│   └── backup-database.sh
└── docs/
    ├── DBA_RUNBOOK.md
    ├── SECURITY_MODEL.md
    ├── RECOVERY_PLAN.md
    └── PROJECT_REPORT.md
```

## Core Database Objects

### Tables
- `RoadAsset`
- `Employee`
- `MaintenanceCrew`
- `CrewMember`
- `Inspection`
- `WorkOrder`
- `WorkOrderHistory`

### Views
- `vw_RoadAssetCondition`
- `vw_OpenWorkOrders`
- `vw_MaintenanceSummary`

### Stored Procedures
- `usp_CreateWorkOrder`
- `usp_CloseWorkOrder`
- `usp_GetRoadMaintenanceHistory`

## Security Model

The project creates three database roles:

| Role | Purpose | Access |
|---|---|---|
| `DBA_Admin` | Database administrators | Broad database administration permissions |
| `DataAnalyst` | Reporting and analysis | SELECT on reporting objects |
| `OperationsUser` | Maintenance operations | Read assets and create/update work orders |

Example users are created without server logins so the security model can be demonstrated safely inside the database.

## Administration Features

### Backup and Recovery
The project contains T-SQL and shell scripts for:

- full database backup
- verifying backup media
- restore to a separate recovery database
- recovery validation

### Monitoring
Monitoring queries inspect:

- active requests
- currently executing SQL
- database file usage
- index usage
- missing-index recommendations
- expensive cached queries
- blocked sessions

### Performance Tuning
The project demonstrates:

- workload-oriented indexes
- execution statistics
- query plans
- index usage analysis
- before/after query structures

### Data Import / Export
A realistic road-asset CSV file is included and imported into a staging table before validated data is moved into the production table.

### Integrity and Maintenance
The maintenance scripts include:

- `DBCC CHECKDB`
- index fragmentation analysis
- statistics updates
- database size checks

### Schema Migration
A controlled migration adds:

- `PriorityCode` to work orders
- a check constraint
- an index used by operational queries

The migration includes idempotency checks so it can be safely rerun.

`Linux` `Technical Documentation`

## Windows setup and verification

See [Windows setup](docs/WINDOWS_SETUP.md) for connection settings and [verified query results](docs/VERIFICATION_RESULTS.txt) for the completed recovery and permission checks.

