EXEC bronze.load_bronze
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @starttime DATETIME ,@endtime DATETIME, @batch_starttime DATETIME , @batch_endtime DATETIME;
	BEGIN TRY
		SET @batch_starttime = GETDATE();
		PRINT '=======================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '=======================================';

		PRINT '---------------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '---------------------------------------';
		SET @starttime = GETDATE();
		PRINT '>> TRUNCATING TABLE : bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info

		PRINT '>> INSERTING INTO : bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info 
		FROM 'C:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
				FIRSTROW = 2,
				FORMAT = 'CSV',
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';

		SET @starttime = GETDATE();
		PRINT '>> TRUNCATING TABLE : bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT '>> INSERTING INTO : bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info 
		FROM 'C:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
				FIRSTROW = 2,
				FORMAT = 'CSV',
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';

		SET @starttime = GETDATE();
		PRINT '>> TRUNCATING TABLE : bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT '>> INSERTING INTO : bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details 
		FROM 'C:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
				FIRSTROW = 2,
				FORMAT = 'CSV',
				FIELDTERMINATOR = ',',
				TABLOCK
		); 
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';
	
		PRINT '---------------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '---------------------------------------';

		SET @starttime = GETDATE();
		PRINT '>> TRUNCATING TABLE : bronze.erp_CUST_AZ12';
		TRUNCATE TABLE bronze.erp_CUST_AZ12
		PRINT '>> INSERTING INTO : bronze.erp_CUST_AZ12';
		BULK INSERT bronze.erp_CUST_AZ12 
		FROM 'C:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
				FIRSTROW = 2,
				FORMAT = 'CSV',
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';

		SET @starttime = GETDATE();
		PRINT '>> TRUNCATING TABLE : bronze.erp_LOC_A101';
		TRUNCATE TABLE bronze.erp_LOC_A101
		PRINT '>> INSERTING INTO : bronze.erp_LOC_A101';
		BULK INSERT bronze.erp_LOC_A101 
		FROM 'C:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
				FIRSTROW = 2,
				FORMAT = 'CSV',
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';

		SET @starttime = GETDATE();
		PRINT '>> TRUNCATING TABLE : bronze.erp_PX_CAT_G1V2';
		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2
		PRINT '>> INSERTING INTO : erp_PX_CAT_G1V2';
		BULK INSERT bronze.erp_PX_CAT_G1V2 
		FROM 'C:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
				FIRSTROW = 2,
				FORMAT = 'CSV',
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';

		SET @batch_endtime = GETDATE();
		PRINT '=============================================================';
		PRINT 'BRONZE LAYER IS COMPLETED';
		PRINT ' TOTAL LOAD DURATION : ' + CAST(DATEDIFF(SECOND , @batch_starttime , @batch_endtime ) AS NVARCHAR) + 'SECONDS';
		PRINT '=============================================================';
	END TRY
	BEGIN CATCH
		PRINT '=============================================================';
		PRINT 'error_message' + ERROR_MESSAGE();
		PRINT 'error_message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'error_message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=============================================================';
	END CATCH
END



