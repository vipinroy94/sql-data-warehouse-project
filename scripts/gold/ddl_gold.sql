/*
======================================================================================
DDL Script: Create Gold Views
======================================================================================
Script Purpose:
  This script create views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (star schema)

  Each view performs transformations and combines data from the silver layer to produc
  a clean, enriched and business ready datasets.

Usage:
  - These views can be queried directly for analytics and reporting.
======================================================================================
*/


-======================================================================================
-- Create Dimension: gold.dim_customers
-======================================================================================

IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
DROP VIEW gold.dim_customer;
GO

  
CREATE VIEW gold.dim_customer AS
SELECT 
  ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
  ci.cst_id AS customer_id,
  ci.cst_key customer_number,
  ci.cst_firstname AS first_name,
  ci.cst_lastname AS last_name,
  ca.BDATE as birthday,
  CASE WHEN ci.cst_gndr !='N/A' THEN ci.cst_gndr
  ELSE COALESCE(ca.gen, 'N/A')
  END AS gender,
  ci.cst_marital_status AS marital_status,
  la.CNTRY as country,
  ci.dwh_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_CUST_AZ12 ca
ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_LOC_A101 la
ON ci.cst_key = la.CID;
GO

-======================================================================================
-- Create Dimension: gold.dim_products
-======================================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT  
  ROW_NUMBER() OVER(Order BY pi.prd_start_dt, pi.prd_key) AS product_key,
  pi.sales_key AS product_id,
  pi.prd_key AS product_number,
  pi.prd_nm AS product_name,
  pi.cat_id AS category_id,
  px.CAT AS category,
  px.SUBCAT AS subcategory,
  px.MAINTENANCE AS maintenance,
  pi.prd_cost AS product_cost,
  pi.prd_line AS product_line,
  pi.prd_start_dt AS start_date
FROM
silver.crm_prd_info pi
LEFT JOIN silver.erp_PX_CAT_G1V2 px
ON pi.cat_id = px.ID;
GO


-======================================================================================
-- Create Fact: gold.fact_sales
-======================================================================================
  
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
DROP VIEW gold.fact_sales;
GO

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 	
	cs.sls_ord_num As order_num,
	cu.customer_key AS customer_key,
	pd.product_key AS product_key,
	cs.sls_order_dt AS order_date,
	cs.sls_ship_dt AS ship_date,
	cs.sls_due_dt AS due_date,
	cs.sls_quantity AS quantity,
	cs.sls_price AS price,
	cs.sls_sales AS sales_value
FROM silver.crm_sales_details cs
LEFT JOIN gold.dim_customer cu
ON cs.sls_cust_id = cu.customer_id
LEFT JOIN gold.dim_products pd
ON cs.sls_prd_key = pd.product_id;
GO



