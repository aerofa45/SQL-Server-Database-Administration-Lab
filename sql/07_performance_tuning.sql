USE TransportationDB;
GO

-- Operational query before indexes
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    w.WorkOrderID,
    w.Status,
    w.RequestedDate,
    w.ScheduledDate,
    r.RouteNumber,
    r.County,
    w.EstimatedCost
FROM dbo.WorkOrder w
JOIN dbo.RoadAsset r ON r.AssetID = w.AssetID
WHERE w.Status IN ('Open','Scheduled','In Progress')
  AND r.County = 'Cole'
ORDER BY w.RequestedDate DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.WorkOrder')
      AND name = 'IX_WorkOrder_Status_RequestedDate'
)
CREATE INDEX IX_WorkOrder_Status_RequestedDate
ON dbo.WorkOrder (Status, RequestedDate DESC)
INCLUDE (AssetID, ScheduledDate, EstimatedCost, CrewID);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.RoadAsset')
      AND name = 'IX_RoadAsset_County_Route'
)
CREATE INDEX IX_RoadAsset_County_Route
ON dbo.RoadAsset (County, RouteNumber)
INCLUDE (ConditionRating, Status, LastInspectionDate);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Inspection')
      AND name = 'IX_Inspection_Asset_Date'
)
CREATE INDEX IX_Inspection_Asset_Date
ON dbo.Inspection (AssetID, InspectionDate DESC)
INCLUDE (ConditionRating, InspectorEmployeeID);
GO

-- Query after indexes
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    w.WorkOrderID,
    w.Status,
    w.RequestedDate,
    w.ScheduledDate,
    r.RouteNumber,
    r.County,
    w.EstimatedCost
FROM dbo.WorkOrder w
JOIN dbo.RoadAsset r ON r.AssetID = w.AssetID
WHERE w.Status IN ('Open','Scheduled','In Progress')
  AND r.County = 'Cole'
ORDER BY w.RequestedDate DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
