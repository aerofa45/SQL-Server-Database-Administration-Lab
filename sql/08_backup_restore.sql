USE master;
GO

DECLARE @BackupPath NVARCHAR(260) =
    '/var/opt/mssql/backups/TransportationDB_full.bak';

BACKUP DATABASE TransportationDB
TO DISK = @BackupPath
WITH INIT,
     COMPRESSION,
     CHECKSUM,
     STATS = 10;
GO

RESTORE VERIFYONLY
FROM DISK = '/var/opt/mssql/backups/TransportationDB_full.bak'
WITH CHECKSUM;
GO

IF DB_ID('TransportationDB_RecoveryTest') IS NOT NULL
BEGIN
    ALTER DATABASE TransportationDB_RecoveryTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TransportationDB_RecoveryTest;
END;
GO

DECLARE @DataFile NVARCHAR(260);
DECLARE @LogFile NVARCHAR(260);

SELECT @DataFile = physical_name
FROM TransportationDB.sys.database_files
WHERE type = 0;

SELECT @LogFile = physical_name
FROM TransportationDB.sys.database_files
WHERE type = 1;

-- The following FILELISTONLY query exposes logical file names used for restore planning.
RESTORE FILELISTONLY
FROM DISK = '/var/opt/mssql/backups/TransportationDB_full.bak';
GO

-- Typical container logical file names created by SQL Server.
RESTORE DATABASE TransportationDB_RecoveryTest
FROM DISK = '/var/opt/mssql/backups/TransportationDB_full.bak'
WITH
    MOVE 'TransportationDB' TO '/var/opt/mssql/data/TransportationDB_RecoveryTest.mdf',
    MOVE 'TransportationDB_log' TO '/var/opt/mssql/data/TransportationDB_RecoveryTest_log.ldf',
    RECOVERY,
    REPLACE,
    STATS = 10;
GO

SELECT
    DB_NAME() AS CurrentDatabase,
    name,
    state_desc,
    recovery_model_desc
FROM sys.databases
WHERE name IN ('TransportationDB','TransportationDB_RecoveryTest');
GO
