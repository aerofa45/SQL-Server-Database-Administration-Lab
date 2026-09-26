USE TransportationDB;
GO
SET NOCOUNT ON;
SELECT name,state_desc,recovery_model_desc FROM sys.databases WHERE name LIKE 'TransportationDB%';
SELECT 'RoadAsset' AS TableName, COUNT(*) AS [RowCount] FROM dbo.RoadAsset
UNION ALL SELECT 'WorkOrder',COUNT(*) FROM dbo.WorkOrder
UNION ALL SELECT 'Recovered RoadAsset',COUNT(*) FROM TransportationDB_RecoveryTest.dbo.RoadAsset
UNION ALL SELECT 'Recovered WorkOrder',COUNT(*) FROM TransportationDB_RecoveryTest.dbo.WorkOrder;
SELECT name,type_desc FROM sys.objects WHERE is_ms_shipped=0 AND type IN ('U','V','P') ORDER BY type,name;
SELECT * FROM dbo.vw_OpenWorkOrders;
EXEC dbo.usp_GetRoadMaintenanceHistory @AssetID=1;
EXECUTE AS USER='demo_analyst';
SELECT USER_NAME() AS DemoUser,HAS_PERMS_BY_NAME('dbo.vw_OpenWorkOrders','OBJECT','SELECT') AS CanReadView,HAS_PERMS_BY_NAME('dbo.WorkOrder','OBJECT','UPDATE') AS CanUpdateWorkOrder;
REVERT;
EXECUTE AS USER='demo_operations';
SELECT USER_NAME() AS DemoUser,HAS_PERMS_BY_NAME('dbo.WorkOrder','OBJECT','UPDATE') AS CanUpdateWorkOrder,HAS_PERMS_BY_NAME(DB_NAME(),'DATABASE','CONTROL') AS CanControlDatabase;
REVERT;
EXECUTE AS USER='demo_dba';
SELECT USER_NAME() AS DemoUser,HAS_PERMS_BY_NAME(DB_NAME(),'DATABASE','CONTROL') AS CanControlDatabase;
REVERT;
DBCC CHECKDB ('TransportationDB') WITH NO_INFOMSGS;
DBCC CHECKDB ('TransportationDB_RecoveryTest') WITH NO_INFOMSGS;
PRINT 'Both database integrity checks completed.';
GO
