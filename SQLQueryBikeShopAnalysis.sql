----Tables in database
SELECT [order_number]
      ,[product_key]
      ,[customer_key]
      ,[order_date]
      ,[shipping_date]
      ,[due_date]
      ,[sales_amount]
      ,[quantity]
      ,[price]
  FROM [DataWarehouseAnalytics].[gold].[fact_sales] 


  SELECT [product_key]
      ,[product_id]
      ,[product_number]
      ,[product_name]
      ,[category_id]
      ,[category]
      ,[subcategory]
      ,[maintenance]
      ,[cost]
      ,[product_line]
      ,[start_date]
  FROM [DataWarehouseAnalytics].[gold].[dim_products]


  SELECT [customer_key]
      ,[customer_id]
      ,[customer_number]
      ,[first_name]
      ,[last_name]
      ,[country]
      ,[marital_status]
      ,[gender]
      ,[birthdate]
      ,[create_date]
  FROM [DataWarehouseAnalytics].[gold].[dim_customers]

---------Change Over Time


SELECT
order_date,
sales_amount
FROM DataWarehouseAnalytics.gold.fact_sales
WHERE order_date IS NOT NULL
ORDER BY order_date 


--SELECT
--YEAR(order_date) AS Order_Year,
--SUM(sales_amount) AS Total_Sales
--FROM gold.fact_sales
--WHERE order_date IS NOT NULL
--GROUP BY YEAR(order_date)
--ORDER BY YEAR(order_date) 


-------BY Year
SELECT
YEAR(order_date) AS Order_Year,
SUM(sales_amount) AS Total_Sales,
COUNT(DISTINCT customer_key) AS Total_customers,
SUM(quantity) AS Total_Quantity
FROM DataWarehouseAnalytics.gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) 

--------BY Month
SELECT
MONTH(order_date) AS Order_Month,
SUM(sales_amount) AS Total_Sales,
COUNT(DISTINCT customer_key) AS Total_customers,
SUM(quantity) AS Total_Quantity
FROM [DataWarehouseAnalytics].[gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date) 


-----Together
SELECT
YEAR(order_date) AS Order_Year,
MONTH(order_date) AS Order_Month,
SUM(sales_amount) AS Total_Sales,
COUNT(DISTINCT customer_key) AS Total_customers,
SUM(quantity) AS Total_Quantity
FROM [DataWarehouseAnalytics].[gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date) 
ORDER BY YEAR(order_date), MONTH(order_date) 

--OR
SELECT
DATETRUNC(MONTH, order_date) AS Order_Date,
SUM(sales_amount) AS Total_Sales,
COUNT(DISTINCT customer_key) AS Total_customers,
SUM(quantity) AS Total_Quantity
FROM [DataWarehouseAnalytics].[gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date)


-----Cumulative 

-----Cal. the total "sales per month" and the "running total of sales over time"

--SELECT
--DATETRUNC(MONTH, order_date) AS Order_Date,
--SUM(sales_amount) AS  Total_Sales
--FROM gold.fact_sales
--WHERE order_date IS NOT NULL
--GROUP BY DATETRUNC(MONTH, order_date)
--ORDER BY DATETRUNC(MONTH, order_date)

---BY Month
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS Running_Total_Sales
FROM
(
SELECT
DATETRUNC(MONTH, order_date) AS Order_Date,
SUM(sales_amount) AS  Total_Sales
FROM [DataWarehouseAnalytics].[gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
) t
---- BY Year
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS Running_Total_Sales
FROM
(
SELECT
DATETRUNC(YEAR, order_date) AS Order_Date,
SUM(sales_amount) AS  Total_Sales
FROM [DataWarehouseAnalytics].[gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
) t


-----+ Moving AVG Price
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS Running_Total_Sales,
AVG(avg_Price) OVER (ORDER BY order_date) AS Moving_Avg_Price
FROM
(
SELECT
DATETRUNC(YEAR, order_date) AS Order_Date,
SUM(sales_amount) AS  Total_Sales,
AVG(price) AS avg_Price
FROM [DataWarehouseAnalytics].[gold].[fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
) t


-----Performace

-----The yearly performance of products by comparing their sales to both the avg sales performance of product and the previous year's sales---

SELECT 
*
FROM [DataWarehouseAnalytics].[gold].[fact_sales] AS f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] AS p
ON f.product_key = p.product_key


--SELECT 
--f.order_date,
--p.product_name,
--f.sales_amount
--FROM gold.fact_sales AS f
--LEFT JOIN gold.dim_products AS p
--ON f.product_key = p.product_key


SELECT 
YEAR(f.order_date) AS Order_Year,
p.product_name,
SUM(f.sales_amount) AS Current_Sales
FROM [DataWarehouseAnalytics].[gold].[fact_sales] AS f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] AS p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name;

---CTE
WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS Order_Year,
p.product_name,
SUM(f.sales_amount) AS Current_Sales
FROM [DataWarehouseAnalytics].[gold].[fact_sales] AS f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] AS p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg
FROM yearly_product_sales
ORDER BY product_name, order_year

---Current sales to the Avg sales performance
WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS Order_Year,
p.product_name,
SUM(f.sales_amount) AS Current_Sales
FROM [DataWarehouseAnalytics].[gold].[fact_sales] AS f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] AS p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change
FROM yearly_product_sales
ORDER BY product_name, order_year

---- Current Sales to the previous year sales
WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS Order_Year,
p.product_name,
SUM(f.sales_amount) AS Current_Sales
FROM [DataWarehouseAnalytics].[gold].[fact_sales] AS f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] AS p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;


----Part to Whole

----Which categories contribute the most to overall sales?

--WITH category_sales AS (
--SELECT 
--category,
--SUM(sales_amount) AS total_sales
--FROM gold.fact_sales AS f
--LEFT JOIN gold.dim_products AS p
--ON f.product_key = p.product_key
--GROUP BY category
--)

--SELECT
--category,
--total_sales,
--SUM(total_sales) OVER() AS overall_sales,
--ROUND((total_sales)*1.00 / SUM(total_sales) OVER ()*100, 2) AS pct_of_total
--FROM category_sales



WITH category_sales AS (
SELECT 
category,
SUM(sales_amount) AS total_sales
FROM [DataWarehouseAnalytics].[gold].[fact_sales] AS f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] AS p
ON f.product_key = p.product_key
GROUP BY category
)

SELECT
category,
total_sales,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ())*100, 2), '%') AS pct_of_total
FROM category_sales
ORDER BY total_sales DESC;


---Data Segmentation

---Segment products into cost ranges and count how many products fall into each segment---

SELECT
product_key,
product_name,
cost
FROM [DataWarehouseAnalytics].[gold].[dim_products]

SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM [DataWarehouseAnalytics].[gold].[dim_products]



WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM [DataWarehouseAnalytics].[gold].[dim_products]
)
SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


---Grouping customers into the 3 segments "VIP", "Regulars", and "New", then find the total number of customers per group---
---VIP: 12 months of history, spending over 5,000
---Regulars: 12 months of history, spending 5,000 or less
---New: less than 12 months

SELECT
c.customer_key,
f.sales_amount,
f.order_date
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON f.customer_key = c.customer_key

----Customer Lifespan
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key;


----CTE

WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regulars'
	 ELSE 'New'
END customer_segment
FROM customer_spending;



WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
	SELECT
	customer_key,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regulars'
		 ELSE 'New'
	END customer_segment
	FROM customer_spending ) t
GROUP BY customer_segment
ORDER BY total_customers DESC



----Key Customer metrics and behaviors


----essential fields: names, ages, and transaction details

WITH base_info AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) age
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

----segment customers into categories and age groups

WITH base_info AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) age
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_date) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_info
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regulars'
	 ELSE 'New'
END customer_segment,
total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
lifespan
FROM customer_aggregation;

----aggregate customer-level metrics (total orders, total sales- total quantity purchased, total products, and lifespan in months)

WITH base_info AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) age
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
)

SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_date) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_info
GROUP BY customer_key, customer_number, customer_name, age;


----Caculate KPI (recency (1- months since last order, 2- avg order value, and 3- avg monthly spend)

--- 1

WITH base_info AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) age
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_date) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_info
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regulars'
	 ELSE 'New'
END customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan
FROM customer_aggregation;


--- 2

WITH base_info AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) age
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_date) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_info
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regulars'
	 ELSE 'New'
END customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value
FROM customer_aggregation;

--- 3

WITH base_info AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) age
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_date) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_info
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regulars'
	 ELSE 'New'
END customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation;


----- Turn into view 

CREATE VIEW gold.report_customers AS 
WITH base_info AS (
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birthdate, GETDATE()) age
FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_date) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_info
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regulars'
	 ELSE 'New'
END customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation;

--SELECT *
--FROM gold.report_customers


---- Key Products metrics and behaviors

WITH base_info AS (
	SELECT
		f.order_number,
		f.customer_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
	LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] p
		ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
),

product_aggregations AS (
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_info
GROUP BY product_key, product_name, category, subcategory, cost
)

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE WHEN total_sales > 50000 THEN 'High-Performer'
		 WHEN total_sales >= 10000 THEN 'Mid-Range'
		 ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS avg_order_revenue,
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregations;

--- Turn into view

CREATE VIEW gold.report_products AS 
WITH base_info AS (
	SELECT
		f.order_number,
		f.customer_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM [DataWarehouseAnalytics].[gold].[fact_sales] f
	LEFT JOIN [DataWarehouseAnalytics].[gold].[dim_products] p
		ON p.product_key = f.product_key
	WHERE order_date IS NOT NULL
),

product_aggregations AS (
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_info
GROUP BY product_key, product_name, category, subcategory, cost
)

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE WHEN total_sales > 50000 THEN 'High-Performer'
		 WHEN total_sales >= 10000 THEN 'Mid-Range'
		 ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS avg_order_revenue,
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregations;

--SELECT *
--FROM gold.report_products