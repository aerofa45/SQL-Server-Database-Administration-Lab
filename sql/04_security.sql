USE TransportationDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'DBA_Admin')
    CREATE ROLE DBA_Admin;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'DataAnalyst')
    CREATE ROLE DataAnalyst;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'OperationsUser')
    CREATE ROLE OperationsUser;
GO

GRANT CONTROL ON DATABASE::TransportationDB TO DBA_Admin;

GRANT SELECT ON dbo.vw_RoadAssetCondition TO DataAnalyst;
GRANT SELECT ON dbo.vw_OpenWorkOrders TO DataAnalyst;
GRANT SELECT ON dbo.vw_MaintenanceSummary TO DataAnalyst;
GRANT EXECUTE ON dbo.usp_GetRoadMaintenanceHistory TO DataAnalyst;

GRANT SELECT ON dbo.RoadAsset TO OperationsUser;
GRANT SELECT ON dbo.MaintenanceCrew TO OperationsUser;
GRANT SELECT, INSERT, UPDATE ON dbo.WorkOrder TO OperationsUser;
GRANT SELECT, INSERT ON dbo.WorkOrderHistory TO OperationsUser;
GRANT EXECUTE ON dbo.usp_CreateWorkOrder TO OperationsUser;
GRANT EXECUTE ON dbo.usp_CloseWorkOrder TO OperationsUser;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'demo_dba')
    CREATE USER demo_dba WITHOUT LOGIN;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'demo_analyst')
    CREATE USER demo_analyst WITHOUT LOGIN;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'demo_operations')
    CREATE USER demo_operations WITHOUT LOGIN;
GO

ALTER ROLE DBA_Admin ADD MEMBER demo_dba;
ALTER ROLE DataAnalyst ADD MEMBER demo_analyst;
ALTER ROLE OperationsUser ADD MEMBER demo_operations;
GO

-- Permission verification
SELECT
    dp.name AS PrincipalName,
    rp.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
WHERE rp.name IN ('DBA_Admin','DataAnalyst','OperationsUser')
ORDER BY rp.name, dp.name;
GO
