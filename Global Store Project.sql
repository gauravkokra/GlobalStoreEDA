# This is a data set of a global store which sells various items ranging from toys to big furnitures. 
# Data set includes sales, quantity, discount, shipping cost all in a single table.

## 1. First we will check Data consistency. Firstly we are checking if the ROW ID is unique or not. So that it can be the primary key. 

    SELECT Row_ID, count(*) 
    FROM globalstore.`globalstore.orders` 
    group by Row_ID 
    having count(*)>1;
    
	#We have no results to show hence, our ROW ID is unique.

## 2. We are checking whether the ship date is lesser than order date or not whereas ideally it should not be.

	SELECT * 
	FROM globalstore.`globalstore.orders` 
	WHERE Order_Date > Ship_Date;

	# The above query is not working because the Dates are in text format and therefore writing a query to change the data type of order date and ship date. 
	# And the format of dates used in mysql is YYYY-MM-DD

	SELECT str_to_date(Order_Date, '%d-%m-%Y') 
	FROM globalstore.`globalstore.orders`;

	-- what we have done in the above query is that we have only selected/viewed and not permanently modified. We	will need to use UPDATE/ALTER

	UPDATE globalstore.`globalstore.orders`
    SET Order_Date = str_to_date(Order_Date, '%d-%m-%Y');
    
    -- Since I tried to UPDATE without using a WHERE clause the system is not allowing me. Getting the following error "Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  
    -- To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
    
    SET SQL_SAFE_UPDATES = 0;
    
    -- Again trying to update the column and changing the format of the date to mysql format
    
    UPDATE globalstore.`globalstore.orders`
    SET Order_Date = str_to_date(Order_Date, '%d-%m-%Y');

	-- Similary doing the same for Ship date also. 
    
    UPDATE globalstore.`globalstore.orders`
    SET Ship_Date = str_to_date(Ship_Date, '%d-%m-%Y');
	
	SELECT * FROM globalstore.`globalstore.orders`;
    
    -- Now the dates have been changed to mysql format. However the data type is still in text. Changing the data type to Date format which requires MySql format of YYYY-MM-DD
    
    ALTER TABLE globalstore.`globalstore.orders`
    MODIFY COLUMN Order_Date DATE;
    
    ALTER TABLE globalstore.`globalstore.orders`
    MODIFY COLUMN Ship_Date DATE;
    
	-- Now checking the data consistency of Order date is greater than ship date.
    
    SELECT * FROM globalstore.`globalstore.orders` WHERE Order_Date>Ship_Date;
    
    -- We are getting no results therefore our with regards to order and ship date is consistent. 
    
# 3. Checking whether our Order ID is unique or not.

	SELECT Order_ID, count(*) 
	FROM globalstore.`globalstore.orders`
	GROUP BY Order_ID;
	
    -- Our Order IDs are not unique
    -- Checking what all details are in a single order
    
    SELECT * 
    FROM globalstore.`globalstore.orders`
    WHERE Order_ID='AG-2011-8180';
    
    SELECT * FROM globalstore.`globalstore.orders`;

# 4. Checking the different types of ship modes we have.

	SELECT distinct Ship_Mode FROM globalstore.`globalstore.orders`;

	-- We have 4 different types of ship modes 1. Same Day 2. First Class 3. Second Class 4. Standard class
    
# 5. Now we are checking the minimum, maximum and average number of days taken to ship an order ranging according to different Order_Priorities

	-- Checking the different order priorities we have. 
    
    SELECT DISTINCT Order_Priority FROM globalstore.`globalstore.orders`;

	-- Order priorities are - LOW, MEDIUM, HIGH, CRITICAL
    
    -- Now we will have to check the minimum and maximum number of days taken to ship an order.
    -- We are creating a new CTE (common table expression). 
    -- This can be done by creating views also but views creates space for itself and is stored while CTEs are used only while the query is being run.
    
		WITH NUMDAYS AS (
		SELECT datediff(Ship_Date,Order_Date) as Numofdays, Order_Date, Ship_Date, Order_Priority
		FROM globalstore.`globalstore.orders`
		)
        
        SELECT min(Numofdays),max(Numofdays),avg(Numofdays)
        FROM NUMDAYS
        WHERE Order_Priority = 'Critical';
        
        -- CRITICAL (min,max,avg) = (0,3,1.8)
        -- HIGH 					(0,5,3.08)
        -- MEDIUM 					(0,7,4.51)
        -- LOW 						(6,7,6.48)
        
        SELECT * FROM globalstore.`globalstore.orders`;
        
# 6. Showing Sum of Sales Region wise in descending order

	SELECT Region,sum(Sales) 
    FROM globalstore.`globalstore.orders`
    GROUP BY Region 
    ORDER BY sum(Sales) desc;
    
    -- Therefore the top 4 sales generating regions for us are Central, South, North, Oceania.
    
    SELECT * FROM globalstore.`globalstore.orders`;
    
	-- Showing sum of sales region wise and country wise
    
	SELECT Region,Country,sum(Sales) 
    FROM globalstore.`globalstore.orders`
    GROUP BY Region,Country 
    ORDER BY Region desc;
    
# 7. Showing Products that have generated negative profit 

	SELECT *   
    FROM globalstore.`globalstore.orders`
    WHERE Profit < 0;
    
# 8. Comparing shipping costs according to order priority and ship mode

	SELECT Ship_Mode,Shipping_Cost,Order_Priority 
    FROM globalstore.`globalstore.orders`;
    
    -- Now we are checking whether standard class shipping is used in orders which are critical or not
    
    SELECT Ship_Mode,Shipping_Cost,Order_Priority 
    FROM globalstore.`globalstore.orders`
    WHERE  Ship_Mode = 'Standard Class' AND Order_Priority = 'Critical';
    
    -- Therefore standard class shipping mode is not used for orders that are critical. 

# 9. Now showing Total Sales and Profit Category wise

	SELECT Category,sum(Sales),sum(Profit)
    FROM globalstore.`globalstore.orders`
    GROUP BY Category;
    
# 10. Now showing Total Sales and Profit Category and Subcategory wise

	SELECT DISTINCT SubCategory
    FROM globalstore.`globalstore.orders`;
    
    -- What we have done below is we are showing sales Category wise and Subcategory wise as well.
    -- Meaning that For each category we are showing sales in descending order subcategory wise
    
    SELECT Category, SubCategory, sum(Sales) AS TotalSales, sum(profit) AS TotalProfit
	FROM globalstore.`globalstore.orders`
    GROUP BY Category,SubCategory
    ORDER BY Category,TotalSales desc;
    
    SELECT * 
	FROM globalstore.`globalstore.orders`;
    
# 11. What are the different markets where the stores are having the best sales?

	SELECT Market,Category, SubCategory, sum(Sales) AS TotalSales, sum(profit) AS TotalProfit
	FROM globalstore.`globalstore.orders`
    GROUP BY Market,Category,SubCategory
    ORDER BY Market,Category,TotalSales desc;
    
	SELECT * FROM globalstore.`globalstore.orders`;
 
-- ------------------------------------------------------------------------------------------------------------------------------------
# 12. CHECKING THE RETURNS TABLE

	SELECT * FROM globalstore.`globalstore.returns`;
    
    -- Checking if any of the orders have been returned
    
    SELECT DISTINCT Returned
    FROM globalstore.`globalstore.returns`;
    
    -- So basically all the orders have been returned and there are no pending orders to be returned
    
# 13. Creating a join between the returns table and orders table. 
    
	SELECT *
	FROM globalstore.`globalstore.returns`
	LEFT JOIN globalstore.`globalstore.orders`
	ON globalstore.`globalstore.returns`.Order_ID = globalstore.`globalstore.orders`.Order_ID;
    
    -- Now the orders that have been returned have to be reduced from the sales and profit numbers. 
    -- Therefore we need add a marker which indicates orders that have been returned or not.
    
    -- Therefore we are now using LEFT JOIN so that we get all the records from the orders table and match the records which are returned . 
    -- This will create another column which has a returns column and through that we can sort which orders have been returned or not and accordingly use to calculate sales/profits.
    
	SELECT *
    FROM globalstore.`globalstore.orders` as o
	LEFT JOIN globalstore.`globalstore.returns` as r
	ON o.Order_ID = r.Order_ID;
    
    -- Using the above result as a CTE and then showing the sales results. 
    
    WITH OrdersReturnsTable AS (
	SELECT 
		o.Order_ID,
        o.Market,
        o.Region,
        o.Category,
        o.SubCategory,
        o.Sales,
        o.Profit,
        r.Returned
    FROM globalstore.`globalstore.orders` as o
	LEFT JOIN globalstore.`globalstore.returns` as r
	ON o.Order_ID = r.Order_ID)
    
    -- We have not used */(selected all columns) as we have 2 columns having same names as Order ID therefore we have selected here
    
    SELECT Category, SubCategory, sum(Sales) AS TotalSales, sum(profit) AS TotalProfit
	FROM OrdersReturnsTable
    WHERE Returned IS NULL
    GROUP BY Category,SubCategory
    ORDER BY Category,TotalSales desc;
    