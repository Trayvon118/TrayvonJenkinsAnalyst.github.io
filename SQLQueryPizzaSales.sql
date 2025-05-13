SELECT [pizza_id]
      ,[order_id]
      ,[pizza_name_id]
      ,[quantity]
      ,[order_date]
      ,[order_time]
      ,[unit_price]
      ,[total_price]
      ,[pizza_size]
      ,[pizza_category]
      ,[pizza_ingredients]
      ,[pizza_name]
  FROM [PorfolioProject].[dbo].[Pizza_Sales]

  ----- Total Revenue

 SELECT SUM(total_price) AS Total_Revenue
 FROM [PorfolioProject]..[Pizza_Sales]

 ----- Average Order Value

 SELECT SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value
 FROM [PorfolioProject]..[Pizza_Sales]


----- Total Pizza Sold

SELECT SUM(quantity) AS Total_Pizza_Sold
FROM Pizza_Sales


---- Total Orders

SELECT COUNT(DISTINCT order_id) AS Total_Orders
FROM Pizza_Sales


-----Average Pizzas Per Orders

SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS Avg_Pizza_Per_Orders
FROM Pizza_Sales


----- Daily Trends Per Orders

SELECT DATENAME(DW, order_date) AS Order_Day, COUNT(DISTINCT order_id) AS Total_Orders
FROM Pizza_Sales
GROUP BY DATENAME(DW, order_date)


----- Hourly Trends

SELECT DATEPART(HOUR, order_time) AS Order_Hours, COUNT(DISTINCT order_id) AS Total_Orders
FROM Pizza_Sales
GROUP BY DATEPART(HOUR, order_time)
ORDER BY DATEPART(HOUR, order_time)


----- % of Sales

SELECT pizza_category,SUM(total_price) AS Total_Sales, SUM(total_price)*100 / (SELECT SUM(total_price) FROM Pizza_Sales) AS pct_of_Sales
FROM Pizza_Sales
GROUP BY pizza_category


SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL (10,2)) AS Total_Sales, CAST(SUM(total_price)*100 / (SELECT SUM(total_price) FROM Pizza_Sales WHERE MONTH(order_date) = 1) AS DECIMAL (10,2)) AS pct_of_Sales
FROM Pizza_Sales
WHERE MONTH(order_date) = 1
GROUP BY pizza_category


---- % of Sales Per Pizza Size

SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL (10,2)) AS Total_Sales, CAST(SUM(total_price)*100 / (SELECT SUM(total_price) FROM Pizza_Sales) AS DECIMAL (10,2)) AS pct_of_Sales
FROM Pizza_Sales
GROUP BY pizza_size
ORDER by pct_of_Sales DESC

SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL (10,2)) AS Total_Sales, CAST(SUM(total_price)*100 / (SELECT SUM(total_price) FROM Pizza_Sales WHERE DATEPART(QUARTER, order_date) = 1) AS DECIMAL (10,2)) AS pct_of_Sales
FROM Pizza_Sales
WHERE DATEPART(QUARTER, order_date) = 1
GROUP BY pizza_size
ORDER by pct_of_Sales DESC

---- Total Pizzas Sold by Pizza Category

SELECT pizza_category, SUM(quantity) AS Total_Pizza_Sold
FROM Pizza_Sales
GROUP BY pizza_category



---- Top 5 Best Sellers by Total Pizza Sold

SELECT pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM Pizza_Sales
GROUP BY pizza_name


SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM Pizza_Sales
GROUP BY pizza_name
ORDER BY SUM(quantity) DESC


----Bottom 5

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM Pizza_Sales
GROUP BY pizza_name
ORDER BY SUM(quantity) ASC

