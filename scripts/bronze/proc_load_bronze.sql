/*
======================================================================================
Stored Procedure : Load Bronze Layer
======================================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncate the bronze tables before loading data.
    - Uses the 'Bulk Insert' command to load data from csv files to bronze tables.
Parameters:
    None.
  This stored procedure does not accept any parameters or returns any values.

Example:
EXEC bronze.load_bronze;
======================================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_data AS

BEGIN
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
	

    BEGIN TRY

		SET @batch_start_time = GETDATE(); 
	    PRINT '==========================================================';
	    PRINT 'Loaing Bronze Layer............';
	    PRINT '==========================================================';

	 
	    PRINT '----------------------------------------------------------';
	    PRINT 'Loading CRM Data...............';
	    PRINT '----------------------------------------------------------';
	
	    

	    PRINT '>>> Truncating bronze.crm_cust_info';
	    TRUNCATE TABLE bronze.crm_cust_info;


	    PRINT '>>> Inserting Date Into : bronze.crm_cust_info';	
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Lenovo\Desktop\SQL\Source Data\CRM\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n'
		);

	    

	    PRINT '>>> Load Duration :' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	    PRINT '----------------------------------------------------------';

	    PRINT '>>> Truncating bronze.crm_prd_info';
	    TRUNCATE TABLE bronze.crm_prd_info;

	    PRINT '>>> Inserting Date Into : bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Lenovo\Desktop\SQL\Source Data\CRM\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n'
		);

	    PRINT '>>> Truncating bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
	    PRINT '>>> Inserting Date Into : bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Lenovo\Desktop\SQL\Source Data\CRM\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n'
		);


	    PRINT '----------------------------------------------------------';
	    PRINT 'Loading ERP Data...............';
	    PRINT '----------------------------------------------------------';

	    PRINT '>>> Truncating bronze.erp_CUST_AZ12';
		TRUNCATE TABLE bronze.erp_CUST_AZ12;
	    PRINT '>>> Inserting Date Into : bronze.erp_CUST_AZ12';
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Users\Lenovo\Desktop\SQL\Source Data\ERP\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n'
		);

	    PRINT '>>> Truncating bronze.erp_LOC_A101';
		TRUNCATE TABLE bronze.erp_LOC_A101;
	    PRINT '>>> Inserting Date Into : bronze.erp_LOC_A101';
		BULK INSERT bronze.erp_LOC_A101
		FROM 'C:\Users\Lenovo\Desktop\SQL\Source Data\ERP\LOC_A101.csv'
		WITH(
			FIRSTROW = 2,
			ROWTERMINATOR = ',',
			FIELDTERMINATOR = '\n'
		);


	    PRINT '>>> Truncating bronze.erp_PX_CAT_G1V2';
		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;
	    PRINT '>>> Inserting Date Into : bronze.erp_PX_CAT_G1V2';
		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\Lenovo\Desktop\SQL\Source Data\ERP\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n'	
		);
		SET @batch_end_time = GETDATE()

		PRINT '==========================================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time,@batch_end_time) AS	NVARCHAR) + 'second';
		PRINT '==========================================================';


	END TRY

	BEGIN CATCH

		PRINT '==========================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + CAST (ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================================';
	
	END CATCH

END
