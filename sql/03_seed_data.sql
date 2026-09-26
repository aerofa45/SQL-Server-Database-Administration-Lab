USE TransportationDB;
GO

INSERT INTO dbo.Employee (EmployeeNumber, FirstName, LastName, JobTitle, Email)
VALUES
('E1001','Jordan','Lee','Database Administrator','jordan.lee@example.local'),
('E1002','Taylor','Morgan','Transportation Analyst','taylor.morgan@example.local'),
('E1003','Casey','Nguyen','Maintenance Supervisor','casey.nguyen@example.local'),
('E1004','Riley','Patel','Road Inspector','riley.patel@example.local'),
('E1005','Avery','Johnson','Operations Specialist','avery.johnson@example.local');
GO

INSERT INTO dbo.MaintenanceCrew (CrewName, District, SupervisorEmployeeID)
VALUES
('Central Pavement Crew','Central',3),
('Bridge Response Crew','Central',3);
GO

INSERT INTO dbo.CrewMember (CrewID, EmployeeID)
VALUES (1,3),(1,5),(2,3),(2,5);
GO

INSERT INTO dbo.RoadAsset
(RouteNumber, County, MileStart, MileEnd, SurfaceType, ConditionRating, Status, LastInspectionDate)
VALUES
('US-50','Cole',120.10,126.40,'Asphalt',7,'Active','2026-08-15'),
('MO-179','Cole',1.20,8.80,'Asphalt',5,'Active','2026-07-02'),
('US-54','Callaway',150.00,158.20,'Concrete',8,'Active','2026-09-01'),
('I-70','Boone',120.00,129.50,'Concrete',6,'Active','2026-08-28'),
('MO-94','Callaway',35.10,41.40,'Asphalt',4,'Restricted','2026-08-20');
GO

INSERT INTO dbo.Inspection
(AssetID, InspectorEmployeeID, InspectionDate, ConditionRating, Notes)
VALUES
(1,4,'2026-08-15',7,'Minor longitudinal cracking observed.'),
(2,4,'2026-07-02',5,'Surface wear and isolated potholes.'),
(3,4,'2026-09-01',8,'Good overall condition.'),
(4,4,'2026-08-28',6,'Moderate joint deterioration.'),
(5,4,'2026-08-20',4,'Drainage and shoulder deterioration require maintenance.');
GO

INSERT INTO dbo.WorkOrder
(AssetID, CrewID, WorkType, Description, Status, RequestedDate, ScheduledDate, EstimatedCost, ActualCost, CreatedByEmployeeID)
VALUES
(2,1,'Pavement Repair','Repair potholes and localized surface failures.','Scheduled','2026-09-02','2026-09-27',18500,NULL,5),
(5,1,'Drainage Repair','Restore ditch flow and stabilize shoulder.','Open','2026-09-05',NULL,32000,NULL,5),
(1,1,'Crack Sealing','Seal longitudinal pavement cracks.','Completed','2026-08-18','2026-08-25',9000,8650,5),
(4,2,'Joint Repair','Repair deteriorated pavement joints.','In Progress','2026-09-10','2026-09-20',42000,NULL,5);
GO

INSERT INTO dbo.WorkOrderHistory
(WorkOrderID, OldStatus, NewStatus, ChangedByEmployeeID, Notes)
VALUES
(1,'Open','Scheduled',5,'Crew assigned and work scheduled.'),
(3,'Scheduled','Completed',5,'Work completed and cost recorded.'),
(4,'Scheduled','In Progress',5,'Work started.');
GO
