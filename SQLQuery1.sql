select *from pizza_sale;

--total revenue 

select sum(total_price) as total_revenue from pizza_sale;

---. Average Order Value
 select (sum(total_price)/count(distinct order_id)) as Avg_order_value from pizza_sale ;

 --3. Total Pizzas Sold
 SELECT SUM(quantity) AS Total_pizza_sold FROM pizza_sale;
 

 --4. Total Orders
  select  count(distinct order_id)  as total_order  from pizza_sale ;
--Average Pizzas Per Order

SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2))
AS Avg_Pizzas_per_order
FROM pizza_sale

--Daily Trend for Total Orders

 select  DATENAME(DW,order_date) as  order_day ,count(distinct order_id)  as total_order 
 from pizza_sale 
 group by DATENAME(DW, order_date);

 --C. Monthly Trend for Orders

  select  DATENAME(MONTH,order_date) as  order_day ,count(distinct order_id)  as total_order 
 from pizza_sale 
 group by DATENAME(MONTH, order_date);


 ---D. % of Sales by Pizza Category

 SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sale) AS DECIMAL(10,2)) AS Percentagee
FROM pizza_sale
GROUP BY pizza_category


--. % of Sales by Pizza Size
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sale) AS DECIMAL(10,2)) AS percentagee
FROM pizza_sale
GROUP BY pizza_size


 ---D. % of Sales by Pizza Category
 --. % of Sales by Pizza Size
 -- by store procdure 
CREATE PROCEDURE percentage_of_sales
    @order1 NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    -- Construct the dynamic SQL query
    SET @SQL = N'
        SELECT 
            ' + QUOTENAME(@order1) + N' AS  (@order1),
            CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue,
            CAST(SUM(total_price) * 100.0 / (SELECT SUM(total_price) FROM pizza_sale) AS DECIMAL(10,2)) AS Percentagee
        FROM 
            pizza_sale
        GROUP BY 
            ' + QUOTENAME(@order1) + N';';

    -- Execute the dynamic SQL query
    EXEC sp_executesql @SQL;
END;

  exec percentage_of_sales  @order1='pizza_category'
  exec percentage_of_sales  @order1='pizza_size'

--. Total Pizzas Sold by Pizza Category
SELECT pizza_category, SUM(quantity) AS Total_pizza_sold 
FROM pizza_sale
GROUP BY pizza_category


-- Top 5 Pizzas by Revenue
select Top 5 pizza_name, sum(total_price) As  Total_revenue from pizza_sale
group by pizza_name
order by total_revenue Desc

--Bottom 5 Pizzas by Revenue
select top 5 pizza_name, sum(total_price) As  Total_revenue from pizza_sale
group by pizza_name
order by total_revenue asc


-- Bottom 5 Pizzas by Quantity

select top 5 pizza_name, sum(quantity) As  quantity from pizza_sale
group by pizza_name
order by quantity asc


--Bottom 5 Pizzas by Quantity

select top 5 pizza_name, sum(quantity) As  quantity from pizza_sale
group by pizza_name
order by quantity desc


--Top 5 Pizzas by Total Orders

SELECT Top 5 pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sale
GROUP BY pizza_name
ORDER BY Total_Orders DESC

--Borrom 5 Pizzas by Total Orders

SELECT Top 5 pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sale
GROUP BY pizza_name
ORDER BY Total_Orders ASC



--- Top 5 Pizzas by Total Orders in classic

SELECT Top 5 pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sale
WHERE pizza_category = 'Classic'
GROUP BY pizza_name
ORDER BY Total_Orders ASC

-- Sum quantity by pizza_name  and   Sum total_price by pizza_name

CREATE PROCEDURE  Pizza_Sales
    @AnalysisType NVARCHAR(50),@type  NVARCHAR(50)
AS
begin 
if @type='top'
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

     SET @SQL = N'
        SELECT top 5
            pizza_name, 
            SUM(' + QUOTENAME(@AnalysisType) + N') AS ' + QUOTENAME(@AnalysisType) + N'
        FROM 
            pizza_sale
        GROUP BY 
            pizza_name
			order by 
			SUM(' + QUOTENAME(@AnalysisType) + N');'
end

else if @type='bottom'
BEGIN
    SET NOCOUNT ON;
	 

     SET @SQL = N'
        SELECT top 5
            pizza_name, 
            SUM(' + QUOTENAME(@AnalysisType) + N') AS ' + QUOTENAME(@AnalysisType) + N'
        FROM 
            pizza_sale
        GROUP BY 
            pizza_name
			order by 
			SUM(' + QUOTENAME(@AnalysisType) + N');'
  end 
     
    EXEC sp_executesql @SQL;
END;




-- Sum total_price by pizza_name
EXEC  Pizza_Sales @AnalysisType = 'total_price', @type ='top';
EXEC  Pizza_Sales @AnalysisType = 'total_price', @type ='bottom';

-- Sum quantity by pizza_name
EXEC  Pizza_Sales @AnalysisType = 'quantity' ,@type ='top';
EXEC  Pizza_Sales @AnalysisType = 'quantity' ,@type ='bottom';


 




-- Bottom 5 Pizzas by Total Orders
CREATE PROCEDURE pizza  
    @AnalysisType NVARCHAR(50),
    @type NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    IF @type = 'bottom'
    BEGIN
        -- Bottom 5 Pizzas by Total Orders
        SET @SQL = N'
            SELECT 
                TOP 5 pizza_name, 
                COUNT(DISTINCT ' + QUOTENAME(@AnalysisType) + N') AS ' + QUOTENAME(@AnalysisType) + N'
            FROM 
                pizza_sale
            GROUP BY 
                pizza_name
            ORDER BY 
                COUNT(DISTINCT ' + QUOTENAME(@AnalysisType) + N') ASC;';
    END
    ELSE IF @type = 'top'
    BEGIN
        -- Top 5 Pizzas by Total Orders
        SET @SQL = N'
            SELECT 
                TOP 5 pizza_name, 
                COUNT(DISTINCT ' + QUOTENAME(@AnalysisType) + N') AS ' + QUOTENAME(@AnalysisType) + N'
            FROM 
                pizza_sale
            GROUP BY 
                pizza_name
            ORDER BY 
                COUNT(DISTINCT ' + QUOTENAME(@AnalysisType) + N') DESC;';
    END;

    -- Execute the dynamic SQL query
    EXEC sp_executesql @SQL;
END;


-- Sum total_price by pizza_name
EXEC pizza  @AnalysisType = 'order_id' ,@type='top';
EXEC pizza  @AnalysisType = 'order_id' ,@type='bottom';

 
