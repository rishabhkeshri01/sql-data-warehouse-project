EXEC silver.load_bronze
CREATE OR ALTER PROCEDURE silver.load_bronze AS 
BEGIN
	DECLARE @starttime DATETIME ,@endtime DATETIME, @batch_starttime DATETIME , @batch_endtime DATETIME;
	BEGIN TRY
		SET @batch_starttime = GETDATE();
		PRINT '=======================================';
		PRINT 'LOADING SILVER LAYER';
		PRINT '=======================================';

		PRINT '---------------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '---------------------------------------';
		SET @starttime = GETDATE();
		PRINT 'FIRST TRUNCATING THE TABLE : silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info
		PRINT 'INSERING VALUES IN TABLE : silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)

		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) as cst_firstname,
		TRIM(cst_lastname) as cst_lastname,
		CASE WHEN cst_marital_status = 'S' THEN 'Single'
			 WHEN cst_marital_status = 'M' THEN 'Married'
			 ELSE 'n/a' END as cst_marital_status,
		CASE WHEN cst_gndr = 'F' THEN 'Female'
			 WHEN cst_gndr = 'M' THEN 'Male'
			 ELSE 'n/a' END as cst_marital_status,
		cst_create_date date
		FROM (
		SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC)
		as flag_last FROM bronze.crm_cust_info
		WHERE cst_id is not null)t
		WHERE flag_last = 1 
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';


		SET @starttime = GETDATE();
		PRINT 'FIRST TRUNCATING THE TABLE : silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info
		PRINT 'INSERING VALUES IN TABLE : silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		SELECT prd_id, 
		REPLACE(SUBSTRING(prd_key,1, 5), '-' , '_') AS cat_id, --extract category id
		SUBSTRING(prd_key, 7 , LEN(prd_key)) as prd_key, 
		prd_nm,
		ISNULL(prd_cost, 0) as prd_cost, 
		CASE 
			WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other sales'
			WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line, -- map prodcut line codes to descriptive values 
		CAST(prd_start_dt AS DATE) AS prd_start_dt, 
		CAST(
			 LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1
			 AS DATE 
			 ) AS prd_start_dt -- calculate the end date as on day before the next start date 
		FROM bronze.crm_prd_info 
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
        PRINT ' ---------------------------------';


		SET @starttime = GETDATE();
		PRINT 'FIRST TRUNCATING THE TABLE : silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details
		PRINT 'INSERING VALUES IN TABLE : silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price 
		)
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN null 
			 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			 END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN null 
			 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
			 END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN null 
			 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
			 END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR  sls_sales != sls_quantity * ABS(sls_price)
			 THEN sls_quantity * ABS(sls_price) ELSE sls_sales END AS sls_sales,  
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <= 0 OR  sls_price != sls_quantity * ABS(sls_sales)
			 THEN sls_quantity * ABS(sls_sales) ELSE sls_price END AS sls_price
		FROM bronze.crm_sales_details
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';
	
		PRINT '---------------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '---------------------------------------';

		SET @starttime = GETDATE();
		PRINT 'FIRST TRUNCATING THE TABLE : silver.erp_CUST_AZ12';
		TRUNCATE TABLE silver.erp_CUST_AZ12
		PRINT 'INSERING VALUES IN TABLE : silver.erp_CUST_AZ12';
		INSERT INTO silver.erp_CUST_AZ12(
		CID,
		BDATE,
		GEN
		)
		SELECT 
		CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING( CID ,4, LEN(CID))
			 ELSE CID END AS CID,
		CASE WHEN BDATE > GETDATE() THEN NULL
		ELSE BDATE END AS BDATE,
		CASE WHEN UPPER(TRIM(GEN)) IN ('F' ,'FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(GEN)) IN ('F' ,'FEMALE') THEN 'MALE'
			 WHEN GEN = ' ' THEN 'N/A'
		ELSE GEN END AS GEN 
		FROM bronze.erp_CUST_AZ12
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';

		SET @starttime = GETDATE();
		PRINT 'FIRST TRUNCATING THE TABLE : silver.erp_LOC_A101';
		TRUNCATE TABLE silver.erp_LOC_A101
		PRINT 'INSERING VALUES IN TABLE : silver.erp_LOC_A101';
		INSERT INTO silver.erp_LOC_A101(CID, CNTRY)
		SELECT
		REPLACE(CID,'-', '') AS CID,
		CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
			 WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
			 WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN 'n/a'
			 ELSE TRIM(CNTRY) 
		END CNTRY
		FROM bronze.erp_LOC_A101  
		SET @endtime = GETDATE();
		PRINT 'LOAD DURATION :' + CAST(DATEDIFF(SECOND , @starttime, @endtime ) AS NVARCHAR) + 'SECOND';
		PRINT '______________';


		SET @starttime = GETDATE();
		PRINT 'FIRST TRUNCATING THE TABLE : silver.erp_PX_CAT_G1V2';
		TRUNCATE TABLE silver.erp_PX_CAT_G1V2
		PRINT 'INSERING VALUES IN TABLE : silver.erp_PX_CAT_G1V2';
		INSERT INTO silver.erp_PX_CAT_G1V2(
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		)
		SELECT 
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		FROM bronze.erp_PX_CAT_G1V2
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
