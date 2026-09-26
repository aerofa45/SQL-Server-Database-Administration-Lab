USE TransportationDB;
GO

IF OBJECT_ID('dbo.RoadAssetImport','U') IS NOT NULL
    DROP TABLE dbo.RoadAssetImport;
GO

CREATE TABLE dbo.RoadAssetImport (
    RouteNumber VARCHAR(20),
    County VARCHAR(80),
    MileStart DECIMAL(8,2),
    MileEnd DECIMAL(8,2),
    SurfaceType VARCHAR(40),
    ConditionRating TINYINT,
    Status VARCHAR(20),
    LastInspectionDate DATE
);
GO

BULK INSERT dbo.RoadAssetImport
FROM '/var/opt/mssql/import/road_assets_import.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
GO

INSERT INTO dbo.RoadAsset
(RouteNumber, County, MileStart, MileEnd, SurfaceType, ConditionRating, Status, LastInspectionDate)
SELECT
    i.RouteNumber,
    i.County,
    i.MileStart,
    i.MileEnd,
    i.SurfaceType,
    i.ConditionRating,
    i.Status,
    i.LastInspectionDate
FROM dbo.RoadAssetImport i
WHERE i.MileEnd > i.MileStart
  AND i.ConditionRating BETWEEN 1 AND 10
  AND i.Status IN ('Active','Restricted','Closed')
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.RoadAsset r
      WHERE r.RouteNumber = i.RouteNumber
        AND r.County = i.County
        AND r.MileStart = i.MileStart
        AND r.MileEnd = i.MileEnd
  );
GO

-- Export-ready dataset:
SELECT
    AssetID, RouteNumber, County, MileStart, MileEnd,
    SurfaceType, ConditionRating, Status, LastInspectionDate
FROM dbo.RoadAsset
ORDER BY County, RouteNumber, MileStart;
GO
