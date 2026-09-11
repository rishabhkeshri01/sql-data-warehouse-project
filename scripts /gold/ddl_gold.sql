-- ========================================================================================
-- CREATE FACT TABLE : gold.dim_customer
-- ========================================================================================
IF OBJECT_ID('gold.dim_customer' , 'V') IS NOT NULL 
   DROP VIEW gold.dim_customer;    
  
GO 

CREATE VIEW gold.dim_customer AS
SELECT 
ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_namen,
    la.CNTRY AS country,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr  -- crm is the master for gender 
         ELSE COALESCE(ca.gen, 'n/a') END AS gender,
    ca.BDATE AS birthday,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN  silver.erp_CUST_AZ12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_LOC_A101 AS la
ON ci.cst_key = la.cid
   
GO

-- ========================================================================================
-- CREATE FACT TABLE : gold.dim_product
-- ========================================================================================
IF OBJECT_ID('gold.dim_product' , 'V') IS NOT NULL 
   DROP VIEW gold.dim_product;    
  
GO

CREATE VIEW gold.dim_product AS 
SELECT 
    ROW_NUMBER() OVER( ORDER BY pn.prd_start_dt , pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
    pn.prd_key AS Product_number ,
    pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
    p.CAT AS category,
    p.SUBCAT AS subcategory,
	p.MAINTENANCE AS maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn  
LEFT JOIN silver.erp_PX_CAT_G1V2 AS p
ON pn.cat_id = p.ID
WHERE prd_end_dt IS NULl 

GO 

-- ========================================================================================
-- CREATE FACT TABLE : gold.fact_sales 
-- ========================================================================================
IF OBJECT_ID('gold.fact_sales' , 'V') IS NOT NULL 
   DROP VIEW gold.fact_sales;

GO

CREATE VIEW gold.fact_sales AS
SELECT 
       sd.sls_ord_num AS order_number ,
       pr.product_key ,
       cu.customer_key,
       sd.sls_order_dt AS order_date ,
       sd.sls_ship_dt AS ship_date ,
       sd.sls_due_dt AS due_date,
       sd.sls_sales AS sales ,
       sd.sls_quantity AS quantity,
       sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_product AS pr
ON sd.sls_prd_key = pr.product_number 
LEFT JOIN gold.dim_customer AS cu 
ON sd.sls_cust_id = cu.customer_id 

