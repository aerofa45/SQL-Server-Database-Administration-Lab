USE TransportationDB;
GO

IF OBJECT_ID('dbo.WorkOrderHistory','U') IS NOT NULL DROP TABLE dbo.WorkOrderHistory;
IF OBJECT_ID('dbo.CrewMember','U') IS NOT NULL DROP TABLE dbo.CrewMember;
IF OBJECT_ID('dbo.WorkOrder','U') IS NOT NULL DROP TABLE dbo.WorkOrder;
IF OBJECT_ID('dbo.Inspection','U') IS NOT NULL DROP TABLE dbo.Inspection;
IF OBJECT_ID('dbo.MaintenanceCrew','U') IS NOT NULL DROP TABLE dbo.MaintenanceCrew;
IF OBJECT_ID('dbo.Employee','U') IS NOT NULL DROP TABLE dbo.Employee;
IF OBJECT_ID('dbo.RoadAsset','U') IS NOT NULL DROP TABLE dbo.RoadAsset;
GO

CREATE TABLE dbo.RoadAsset (
    AssetID            INT IDENTITY(1,1) PRIMARY KEY,
    RouteNumber        VARCHAR(20) NOT NULL,
    County             VARCHAR(80) NOT NULL,
    MileStart          DECIMAL(8,2) NOT NULL,
    MileEnd            DECIMAL(8,2) NOT NULL,
    SurfaceType        VARCHAR(40) NOT NULL,
    ConditionRating    TINYINT NOT NULL,
    Status             VARCHAR(20) NOT NULL DEFAULT 'Active',
    LastInspectionDate DATE NULL,
    CreatedAt          DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_RoadAsset_Miles CHECK (MileEnd > MileStart),
    CONSTRAINT CK_RoadAsset_Condition CHECK (ConditionRating BETWEEN 1 AND 10),
    CONSTRAINT CK_RoadAsset_Status CHECK (Status IN ('Active','Restricted','Closed'))
);
GO

CREATE TABLE dbo.Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeNumber VARCHAR(20) NOT NULL UNIQUE,
    FirstName VARCHAR(60) NOT NULL,
    LastName VARCHAR(60) NOT NULL,
    JobTitle VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dbo.MaintenanceCrew (
    CrewID INT IDENTITY(1,1) PRIMARY KEY,
    CrewName VARCHAR(100) NOT NULL UNIQUE,
    District VARCHAR(50) NOT NULL,
    SupervisorEmployeeID INT NULL,
    CONSTRAINT FK_MaintenanceCrew_Supervisor
        FOREIGN KEY (SupervisorEmployeeID) REFERENCES dbo.Employee(EmployeeID)
);
GO

CREATE TABLE dbo.CrewMember (
    CrewID INT NOT NULL,
    EmployeeID INT NOT NULL,
    AssignedDate DATE NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (CrewID, EmployeeID),
    CONSTRAINT FK_CrewMember_Crew FOREIGN KEY (CrewID) REFERENCES dbo.MaintenanceCrew(CrewID),
    CONSTRAINT FK_CrewMember_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employee(EmployeeID)
);
GO

CREATE TABLE dbo.Inspection (
    InspectionID INT IDENTITY(1,1) PRIMARY KEY,
    AssetID INT NOT NULL,
    InspectorEmployeeID INT NOT NULL,
    InspectionDate DATE NOT NULL,
    ConditionRating TINYINT NOT NULL,
    Notes VARCHAR(1000) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Inspection_RoadAsset FOREIGN KEY (AssetID) REFERENCES dbo.RoadAsset(AssetID),
    CONSTRAINT FK_Inspection_Employee FOREIGN KEY (InspectorEmployeeID) REFERENCES dbo.Employee(EmployeeID),
    CONSTRAINT CK_Inspection_Condition CHECK (ConditionRating BETWEEN 1 AND 10)
);
GO

CREATE TABLE dbo.WorkOrder (
    WorkOrderID INT IDENTITY(1,1) PRIMARY KEY,
    AssetID INT NOT NULL,
    CrewID INT NULL,
    WorkType VARCHAR(80) NOT NULL,
    Description VARCHAR(1000) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Open',
    RequestedDate DATE NOT NULL DEFAULT GETDATE(),
    ScheduledDate DATE NULL,
    CompletedDate DATE NULL,
    EstimatedCost DECIMAL(12,2) NULL,
    ActualCost DECIMAL(12,2) NULL,
    CreatedByEmployeeID INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ModifiedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_WorkOrder_RoadAsset FOREIGN KEY (AssetID) REFERENCES dbo.RoadAsset(AssetID),
    CONSTRAINT FK_WorkOrder_Crew FOREIGN KEY (CrewID) REFERENCES dbo.MaintenanceCrew(CrewID),
    CONSTRAINT FK_WorkOrder_Employee FOREIGN KEY (CreatedByEmployeeID) REFERENCES dbo.Employee(EmployeeID),
    CONSTRAINT CK_WorkOrder_Status CHECK (Status IN ('Open','Scheduled','In Progress','Completed','Cancelled'))
);
GO

CREATE TABLE dbo.WorkOrderHistory (
    HistoryID BIGINT IDENTITY(1,1) PRIMARY KEY,
    WorkOrderID INT NOT NULL,
    OldStatus VARCHAR(20) NULL,
    NewStatus VARCHAR(20) NOT NULL,
    ChangedByEmployeeID INT NULL,
    ChangedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Notes VARCHAR(500) NULL,
    CONSTRAINT FK_WorkOrderHistory_WorkOrder FOREIGN KEY (WorkOrderID) REFERENCES dbo.WorkOrder(WorkOrderID),
    CONSTRAINT FK_WorkOrderHistory_Employee FOREIGN KEY (ChangedByEmployeeID) REFERENCES dbo.Employee(EmployeeID)
);
GO

CREATE OR ALTER VIEW dbo.vw_RoadAssetCondition
AS
SELECT
    AssetID,
    RouteNumber,
    County,
    MileStart,
    MileEnd,
    SurfaceType,
    ConditionRating,
    Status,
    LastInspectionDate,
    CASE
        WHEN ConditionRating <= 3 THEN 'Critical'
        WHEN ConditionRating <= 5 THEN 'Poor'
        WHEN ConditionRating <= 7 THEN 'Fair'
        ELSE 'Good'
    END AS ConditionCategory
FROM dbo.RoadAsset;
GO

CREATE OR ALTER VIEW dbo.vw_OpenWorkOrders
AS
SELECT
    w.WorkOrderID,
    r.RouteNumber,
    r.County,
    w.WorkType,
    w.Status,
    w.RequestedDate,
    w.ScheduledDate,
    c.CrewName,
    w.EstimatedCost
FROM dbo.WorkOrder w
JOIN dbo.RoadAsset r ON r.AssetID = w.AssetID
LEFT JOIN dbo.MaintenanceCrew c ON c.CrewID = w.CrewID
WHERE w.Status NOT IN ('Completed','Cancelled');
GO

CREATE OR ALTER VIEW dbo.vw_MaintenanceSummary
AS
SELECT
    r.County,
    COUNT(*) AS WorkOrderCount,
    SUM(CASE WHEN w.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedCount,
    SUM(COALESCE(w.ActualCost,0)) AS TotalActualCost
FROM dbo.WorkOrder w
JOIN dbo.RoadAsset r ON r.AssetID = w.AssetID
GROUP BY r.County;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CreateWorkOrder
    @AssetID INT,
    @CrewID INT = NULL,
    @WorkType VARCHAR(80),
    @Description VARCHAR(1000),
    @EstimatedCost DECIMAL(12,2) = NULL,
    @CreatedByEmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.WorkOrder
        (AssetID, CrewID, WorkType, Description, EstimatedCost, CreatedByEmployeeID)
    VALUES
        (@AssetID, @CrewID, @WorkType, @Description, @EstimatedCost, @CreatedByEmployeeID);

    SELECT SCOPE_IDENTITY() AS NewWorkOrderID;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_CloseWorkOrder
    @WorkOrderID INT,
    @ActualCost DECIMAL(12,2),
    @ChangedByEmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DECLARE @OldStatus VARCHAR(20);

    SELECT @OldStatus = Status
    FROM dbo.WorkOrder WITH (UPDLOCK, ROWLOCK)
    WHERE WorkOrderID = @WorkOrderID;

    UPDATE dbo.WorkOrder
    SET Status = 'Completed',
        CompletedDate = CAST(GETDATE() AS DATE),
        ActualCost = @ActualCost,
        ModifiedAt = SYSUTCDATETIME()
    WHERE WorkOrderID = @WorkOrderID;

    INSERT INTO dbo.WorkOrderHistory
        (WorkOrderID, OldStatus, NewStatus, ChangedByEmployeeID, Notes)
    VALUES
        (@WorkOrderID, @OldStatus, 'Completed', @ChangedByEmployeeID, 'Closed using usp_CloseWorkOrder');

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetRoadMaintenanceHistory
    @AssetID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        w.WorkOrderID,
        w.WorkType,
        w.Status,
        w.RequestedDate,
        w.CompletedDate,
        w.EstimatedCost,
        w.ActualCost
    FROM dbo.WorkOrder w
    WHERE w.AssetID = @AssetID
    ORDER BY w.RequestedDate DESC, w.WorkOrderID DESC;
END;
GO
