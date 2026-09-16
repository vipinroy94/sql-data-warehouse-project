/*
======================================================================================
Quality Checks
======================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy, and standardization
  across the 'silver' schema. It includes check for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid dates and orders
  - Data consistency between related fields.

Usage:
  - Run these checks after data loading silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
======================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_data AS

BEGIN
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
BEGIN TRY
	SET @batch_start_time = GETDATE();

	PRINT '==========================================================';
	PRINT 'Loaing Silver Layer............';
	PRINT '==========================================================';


	PRINT '----------------------------------------------------------';
	PRINT 'Loading CRM Data...............';
	PRINT '----------------------------------------------------------';


	PRINT '>>Truncating Table : silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;

	PRINT '>>Insering Data Ito : silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info(
	cst_id ,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)
	SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) As cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Single'
		 WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Married'
		 ELSE 'N/A'
	END cst_marital_status,
	CASE WHEN TRIM(UPPER(cst_gndr)) =  'M' THEN 'Male'
		 WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
		 ELSE 'N/A'
	END cst_gndr, 
	cst_create_date
	FROM
	(Select *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Rank_Flag
	From bronze.crm_cust_info WHERE cst_id IS NOT NULL)t WHERE Rank_Flag = 1;


	PRINT '>>Truncating Table : silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;

	PRINT '>>Insering Data Ito : silver.crm_prd_info';
	INSERT INTO silver.crm_prd_info(
	prd_id,
	prd_key,
	cat_id,
	sales_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)

	SELECT 
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') As cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS sales_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		 ELSE 'N/A'
	END prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS  date) prd_end_dt
	FROM bronze.crm_prd_info;


	PRINT '>>Truncating Table : silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;

	PRINT '>>Insering Data Ito : silver.crm_sales_details';
	INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_quantity,
	sls_price,
	sls_sales
	)
	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_quantity,

	CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN
	sls_sales/NULLIF(sls_quantity,0) ELSE sls_price END AS sls_price,

	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales !=sls_quantity*sls_price THEN
	sls_quantity * abs(sls_price) ELSE sls_sales END AS sls_sales
	FROM bronze.crm_sales_details;


	PRINT '----------------------------------------------------------';
	PRINT 'Loading CRM Data...............';
	PRINT '----------------------------------------------------------';



	PRINT '>>Truncating Table : silver.erp_CUST_AZ12';
	TRUNCATE TABLE silver.erp_CUST_AZ12;

	PRINT '>>Insering Data Ito : silver.erp_CUST_AZ12';
	INSERT INTO silver.erp_CUST_AZ12 (
	CID,
	BDATE,
	GEN
	)
	Select 

	CASE
	WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
	ELSE CID END AS CID,

	CASE
	WHEN BDATE > GETDATE() THEN NULL
	ELSE BDATE
	END AS BDATE,

	CASE
	WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'N/A'
	END AS GEN
	FROM bronze.erp_CUST_AZ12;

	PRINT '>>Truncating Table : silver.erp_LOC_A101';
	TRUNCATE TABLE silver.erp_LOC_A101;

	PRINT '>>Insering Data Ito : silver.erp_LOC_A101';
	INSERT INTO silver.erp_LOC_A101(
	CNTRY,
	cid
	)
	SELECT 
	CASE
	WHEN Upper(TRIM(CID)) IN ('USA','US','United States') THEN 'USA'
	WHEN UPPER(TRIM(CID)) IN ('DE', 'Germany') Then 'Germary'
	WHEN TRIM(CID) = '' OR CID IS NULL THEN 'N/A'
	ELSE CID
	END AS CID,
	REPLACE(CNTRY, '-','') AS CNTRY
	FROM bronze.erp_LOC_A101;

	PRINT '>>Truncating Table : silver.erp_PX_CAT_G1V2';
	TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
	PRINT '>>Insering Data Ito : silver.erp_PX_CAT_G1V2';
	INSERT INTO silver.erp_PX_CAT_G1V2(
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	)

	SELECT 
	TRIM(ID) AS ID,
	TRIM(CAT) AS CAT,
	TRIM(SUBCAT) AS SUBCAT,
	TRIM(MAINTENANCE) AS MAINTENANCE
	FROM bronze.erp_PX_CAT_G1V2;


	SET @batch_end_time = GETDATE();
	SET @batch_start_time

	PRINT '==========================================================';
	PRINT 'Loading Silver Layer is Completed';
	PRINT 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time , @batch_end_time) AS	NVARCHAR) + 'second';
	PRINT '==========================================================';

END TRY
BEGIN CATCH
	PRINT '==========================================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + CAST (ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================================';
END CATCH	

END
