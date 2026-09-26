IF DB_ID('TransportationDB') IS NULL
BEGIN
    CREATE DATABASE TransportationDB;
END;
GO

ALTER DATABASE TransportationDB SET RECOVERY SIMPLE;
GO

USE TransportationDB;
GO
