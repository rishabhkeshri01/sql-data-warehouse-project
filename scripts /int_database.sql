USE master;
GO

-- drop and recreate the datawarehouse dataset 
IF EXISTS ( SELECT 1 FROM sys.databases where name = 'DataWarehouse' ) 
BEGIN 
		ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE DataWarehouse;
END;
GO

-- create a datawarehouse dataset
CREATE DATABASE DataWarehouse; 
GO
USE DataWarehouse;
GO
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
