USE TransportationDB;
GO

IF COL_LENGTH('dbo.WorkOrder','PriorityCode') IS NULL
BEGIN
    ALTER TABLE dbo.WorkOrder
    ADD PriorityCode VARCHAR(10) NOT NULL
        CONSTRAINT DF_WorkOrder_PriorityCode DEFAULT 'Normal';
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_WorkOrder_PriorityCode'
)
BEGIN
    ALTER TABLE dbo.WorkOrder
    ADD CONSTRAINT CK_WorkOrder_PriorityCode
    CHECK (PriorityCode IN ('Low','Normal','High','Emergency'));
END;
GO

UPDATE dbo.WorkOrder
SET PriorityCode =
    CASE
        WHEN WorkType LIKE '%Drainage%' THEN 'High'
        WHEN EstimatedCost >= 40000 THEN 'High'
        ELSE 'Normal'
    END
WHERE PriorityCode = 'Normal';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.WorkOrder')
      AND name = 'IX_WorkOrder_Priority_Status'
)
BEGIN
    CREATE INDEX IX_WorkOrder_Priority_Status
    ON dbo.WorkOrder (PriorityCode, Status)
    INCLUDE (AssetID, RequestedDate, EstimatedCost);
END;
GO

SELECT
    WorkOrderID,
    WorkType,
    PriorityCode,
    Status,
    RequestedDate
FROM dbo.WorkOrder
ORDER BY
    CASE PriorityCode
        WHEN 'Emergency' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Normal' THEN 3
        ELSE 4
    END,
    RequestedDate;
GO
