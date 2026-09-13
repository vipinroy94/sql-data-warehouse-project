/*
=======================================================
Create Database and schemas
=======================================================

Script Purpose:
    This script creates a new database named 'Datawarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution and 
    ensure you have proper backups before running this script.
*/

USE master;
GO

--- Drop and recreate the 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases where name = 'Datawarehouse')

BEGIN
	ALTER DATABASE Datawarehouse SET SINGLE_USER with ROLLBACK IMMEDIATE;
	DROP Database Datawarehouse;
END;
GO

--Create the 'Datawarehouse' database
CREATE DATABASE Datawarehouse;
GO

USE Datawarehouse;
GO

-- Create Schemas 
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO


