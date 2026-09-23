/*
-======================================================================================
-- Quality Checks
-======================================================================================
Script Purpose:
	This script perform quality checks to validate the integrity, consitency, and accuracy
	of the Gold Layer. These checks ensure:
	- Uniqueness of surrogate keys in dimension tables.
	- Referential integrity between fact and dimension tables.
	- Validation of releationships in the data model for analytical purposes.
Usage Note:
	- Run these checks after data loading Silver Layer.
	- Investigate and resolve any discrepancies found during checks.
-======================================================================================
*/

-======================================================================================
-- Checking: gold.dim_customers
-======================================================================================
-- Check for uniqueness of product key in gold.dim_products
-- Expectation: No results
SELECT 
	customer_key,
	count(*) AS duplicat_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) >1;
	
-======================================================================================
-- Checking: gold.dim_products
-======================================================================================
-- Check for uniqueness of product key in gold.dim_products
-- Expectation: No results

SELECT 
	product_key,
	count(*) AS duplicates_count
FROM gold.dim_products
GROUP BY product_key
HAVING count(*) >1;

-======================================================================================
-- Checking: gold.fact_sales
-======================================================================================
--Check the data model connectivity between fact and dimensions
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;


