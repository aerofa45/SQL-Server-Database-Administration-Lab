USE TransportationDB;
GO

DBCC CHECKDB ('TransportationDB') WITH NO_INFOMSGS;
GO

-- Fragmentation report
SELECT
    OBJECT_SCHEMA_NAME(ips.object_id) AS SchemaName,
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN sys.indexes i
  ON ips.object_id = i.object_id
 AND ips.index_id = i.index_id
WHERE ips.index_id > 0
ORDER BY ips.avg_fragmentation_in_percent DESC;
GO

-- Statistics maintenance
EXEC sp_updatestats;
GO

-- Database size summary
SELECT
    DB_NAME(database_id) AS DatabaseName,
    type_desc,
    SUM(size) * 8.0 / 1024 AS SizeMB
FROM sys.master_files
WHERE database_id = DB_ID('TransportationDB')
GROUP BY database_id, type_desc;
GO
