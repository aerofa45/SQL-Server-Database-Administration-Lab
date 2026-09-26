USE TransportationDB;
GO

-- Active user requests
SELECT
    r.session_id,
    r.status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time,
    r.logical_reads,
    r.writes,
    DB_NAME(r.database_id) AS DatabaseName,
    SUBSTRING(
        t.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(t.text)
            ELSE r.statement_end_offset
          END - r.statement_start_offset) / 2) + 1
    ) AS RunningStatement
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id <> @@SPID;
GO

-- Database files and used space
SELECT
    name AS LogicalFileName,
    type_desc,
    size * 8.0 / 1024 AS SizeMB,
    FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 AS SpaceUsedMB
FROM sys.database_files;
GO

-- Index usage
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    COALESCE(s.user_seeks,0) AS UserSeeks,
    COALESCE(s.user_scans,0) AS UserScans,
    COALESCE(s.user_lookups,0) AS UserLookups,
    COALESCE(s.user_updates,0) AS UserUpdates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
    ON s.database_id = DB_ID()
   AND s.object_id = i.object_id
   AND s.index_id = i.index_id
WHERE i.object_id > 0
  AND i.name IS NOT NULL
ORDER BY COALESCE(s.user_seeks,0) + COALESCE(s.user_scans,0) + COALESCE(s.user_lookups,0) DESC;
GO

-- Expensive cached queries
SELECT TOP 10
    qs.execution_count,
    qs.total_worker_time / NULLIF(qs.execution_count,0) AS AvgCPU,
    qs.total_elapsed_time / NULLIF(qs.execution_count,0) AS AvgElapsed,
    qs.total_logical_reads / NULLIF(qs.execution_count,0) AS AvgLogicalReads,
    LEFT(st.text, 1000) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY AvgLogicalReads DESC;
GO

-- Blocking sessions
SELECT
    r.session_id,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    t.text AS SqlText
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0;
GO

-- Missing index suggestions
SELECT TOP 10
    migs.avg_total_user_cost,
    migs.avg_user_impact,
    migs.user_seeks,
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_group_stats migs
JOIN sys.dm_db_missing_index_groups mig
  ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid
  ON mig.index_handle = mid.index_handle
WHERE mid.database_id = DB_ID()
ORDER BY migs.avg_user_impact * migs.user_seeks DESC;
GO
