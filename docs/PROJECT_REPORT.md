# Project Report

## Project
Transportation Asset Management SQL Server DBA Lab

## Objective

Build a realistic relational database environment that demonstrates entry-level database administration responsibilities in an operational setting.

## Business Context

Transportation agencies depend on reliable databases for asset records, inspections, maintenance schedules, employee information, and work-order tracking. The database must remain available, secure, recoverable, and responsive while serving different groups of users.

## Implemented Components

### Database Design
A normalized SQL Server schema was created for road assets, inspections, maintenance crews, employees, work orders, and work-order status history.

### Administration
The repository includes database creation, schema deployment, seed data, controlled migrations, integrity checks, backup and recovery, and maintenance scripts.

### Security
Role-based access control separates administrative, analytical, and operational responsibilities. Database permissions are assigned through roles and tested using contained demo users.

### Data Movement
A CSV road-asset dataset is loaded into a staging table using SQL Server bulk import. Validation rules prevent invalid records from entering the production table.

### Performance
Operational indexes target common filters for work-order status, request date, county, route, and asset inspection history. Monitoring scripts expose expensive queries, active sessions, index usage, blocking, and missing-index recommendations.

### Recovery
A full backup uses CHECKSUM and COMPRESSION. The project validates the backup and restores it to a separate recovery-test database.

### Documentation
The project includes an operational DBA runbook, security model, and recovery plan.

## DBA Responsibilities Demonstrated

| Responsibility | Project Evidence |
|---|---|
| Maintain databases | database creation, schema deployment, maintenance |
| Create database objects | tables, constraints, views, indexes, procedures |
| SQL scripting | complete T-SQL deployment scripts |
| Manage access | users, roles, permissions |
| Data security | least-privilege RBAC model |
| Import/export | CSV staging and validated ingestion |
| Backup/restore | full backup, verification, recovery-test restore |
| Monitor performance | DMVs for requests, queries, indexes and blocking |
| Optimize performance | indexes and statistics |
| Database integrity | DBCC CHECKDB |
| Migration | idempotent schema migration |
| Documentation | runbook, security model, recovery plan |

## Technology

- Microsoft SQL Server 2022
- T-SQL
- Docker / Docker Compose
- Bash
- CSV bulk import
- SQL Server dynamic management views

## Portfolio Value

This project provides concrete evidence of hands-on database administration rather than only database application development. It demonstrates the operational skills expected in an entry-level SQL Server DBA or database-focused information systems role.
