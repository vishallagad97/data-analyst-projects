CREATE DATABASE coffee_sale;
USE coffee_sale;

SELECT * FROM coffee_shop;

desc coffee_shop;

-- DATA VALIDATION

# Changing data type of transaction date to date 
SET SQL_SAFE_UPDATES = 0;
UPDATE coffee_shop
SET transaction_date = 
STR_TO_DATE(transaction_date, '%m/%d/%Y');

ALTER TABLE coffee_shop
MODIFY transaction_date  DATE;

# ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
ALTER TABLE coffee_shop
MODIFY COLUMN transaction_time TIME;

DESC coffee_shop;

# CHANGING COLUMN NAME `ï»¿transaction_id` to transaction_id
ALTER TABLE coffee_shop
CHANGE COLUMN `ï»¿transaction_id` transaction_id INT;

# Check for NULL Values

SELECT 
	SUM(transaction_id IS NULL) AS null_transaction_id,
    SUM(transaction_date IS NULL) AS null_transaction_date,
    SUM(transaction_time IS NULL) AS null_transaction_time,
    SUM(transaction_qty IS NULL) AS null_quantity,
    SUM(unit_price IS NULL) AS null_unit_price,
    SUM(store_location IS NULL) AS null_store_location,
    SUM(product_category IS NULL) AS null_product_category
FROM coffee_shop;

# CHECK for Invalid Quantities
SELECT * FROM coffee_shop WHERE transaction_qty <= 0;

# Check for Invalid Prices
SELECT * FROM coffee_shop WHERE unit_price <= 0;

# duplicate Transaction Check
SELECT transaction_id, COUNT(*) AS duplicate_count
FROM coffee_shop
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Data Transformation (Derived Fields)

-- Create a View with Revenue Calculation
CREATE VIEW revenue AS 
SELECT 
	transaction_id,
    transaction_date,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,
    product_category,
    product_type,
    product_detail,
    unit_price,
    transaction_qty * unit_price AS revenue
FROM coffee_shop;

SELECT * FROM revenue;

# Add Time-Based Attributes
CREATE VIEW  trend_data AS 
SELECT 
	*,
    HOUR(transaction_time) AS sales_hour,
    DAYNAME(transaction_date) AS sales_day,
    MONTH(transaction_date) AS sales_month,
    YEAR(transaction_date) AS sales_year
FROM revenue;

SELECT * FROM TREND_DATA;

-------------------------------------------------------------------------------------------------------------------------------------------------------
# Exploratory Business Analysis Using SQL

#1 Total Revenue
SELECT SUM(revenue) AS total_revenue
FROM revenue;

#2 Revenue by Store Location
SELECT 
	store_location,
    SUM(revenue) AS total_revenue
FROM revenue
GROUP BY store_location
ORDER BY total_revenue DESC;

#3 Revenue by Product Category
SELECT
	product_category,
    SUM(revenue) AS total_revenue
FROM revenue
GROUP BY product_category
ORDER BY total_revenue DESC;

#4 Top 10 Product by Revenue
SELECT
	product_detail,
    SUM(revenue) AS total_revenue
FROM revenue
GROUP BY product_detail
ORDER BY total_revenue DESC
LIMIT 10;

select * from coffee_shop;

#5 Hourly Sales Trend
SELECT 
	sales_hour,
    SUM(revenue) AS hourly_revenue
FROM trend_data
GROUP BY sales_hour
ORDER BY sales_hour;

#6 Daily Sales Trend
SELECT
	transaction_date,
    SUM(revenue) AS daily_revenue
FROM trend_data
GROUP BY transaction_date
ORDER BY transaction_date;

#7 Monthly Sales Trend
SELECT 
	sales_year,
    sales_month,
    SUM(revenue) AS monthly_revenue
FROM trend_data
GROUP BY sales_year, sales_month
ORDER BY sales_year, sales_month;

#7 Day Sales Trend
SELECT 
	sales_day,
    SUM(revenue) AS sales_daily_revenue
FROM trend_data
GROUP BY sales_day
ORDER BY sales_day;

#8 Location and Day wise Sales Trend
SELECT 
	store_location,
    sales_day,
    SUM(revenue) AS location_wise_revenue
FROM trend_data
GROUP BY store_location, sales_day
ORDER BY sales_day;

#9 Location, day, and product category wise sales trend
SELECT 
	store_location,
    sales_day,
    product_category,
    SUM(revenue) AS location_wise_revenue
FROM trend_data
GROUP BY store_location, sales_day,product_category;


# TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY 
SELECT 
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END AS Day_of_Week,
    ROUND(SUM(unit_price*transaction_qty)) AS Total_Sales
FROM
	coffee_shop
WHERE
	MONTH(transaction_date) = 5 -- Filtering for May (month number 5)
GROUP BY
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END;
    
------------------------------------------------------------------------------------------------------------------------------------------------------

-- CORE KPI calculations
#1. Total Orders
SELECT 
	COUNT(DISTINCT transaction_id) AS total_orders
FROM coffee_shop;

#2. Total Revenue
SELECT 
	ROUND(SUM(transaction_qty * unit_price), 2) AS total_revenue
FROM coffee_shop;

#3. Average Order Value(AOV)
-- How much each customer spends on each visit
SELECT ROUND(SUM(transaction_qty * unit_price) / COUNT(DISTINCT transaction_id), 2)
	AS avg_order_value FROM coffee_shop;
    


		
        


