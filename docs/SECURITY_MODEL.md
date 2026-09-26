# Security Model

## Goal

Separate administrative, analytical, and operational duties while minimizing unnecessary privileges.

## Roles

### DBA_Admin
Purpose:
- database administration
- schema maintenance
- troubleshooting
- recovery operations

Permission:
- `CONTROL DATABASE`

### DataAnalyst
Purpose:
- reporting
- analysis
- read-only access to curated data

Permissions:
- SELECT on reporting views
- EXECUTE on read-only maintenance-history procedure

The analyst is not granted direct INSERT, UPDATE, DELETE, ALTER, or CONTROL permissions.

### OperationsUser
Purpose:
- operational work-order processing

Permissions:
- SELECT on road assets and maintenance crews
- SELECT/INSERT/UPDATE on work orders
- INSERT into work-order history
- EXECUTE on operational stored procedures

## Least Privilege

Permissions are assigned to roles rather than directly to users. Users are then added to the appropriate role.

This provides:
- simpler access management
- consistent privilege assignment
- easier access review
- reduced risk of accidental over-permissioning

## Demo Principals

The project creates contained demonstration users without server logins:
- `demo_dba`
- `demo_analyst`
- `demo_operations`

This allows role membership and permission structures to be inspected without creating external credentials.
