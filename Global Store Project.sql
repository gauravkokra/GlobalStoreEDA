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
    
# 5. Now we are checking the minimum and maximum number of days taken to ship an order ranging according to different Order_Priorities

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
        
        SELECT min(Numofdays),max(Numofdays) 
        FROM NUMDAYS
        WHERE Order_Priority = 'High';
        
        -- CRITICAL (min,max) = (0,3)
        -- 
        
        SELECT * FROM globalstore.`globalstore.orders`
        