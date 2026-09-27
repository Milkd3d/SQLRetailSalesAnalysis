---- SQL Retail Sales Analysis

CREATE DATABASE sqlProject;

--- CREATE TABLE

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
			(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),
				age	INT,
				category VARCHAR(15),
				quantity INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);
			
--- Confirming data imported correctly

SELECT * FROM retail_sales
LIMIT 10;

SELECT count(*) FROM retail_sales;

--- Cleaning Data

-- Checking for null values

SELECT * FROM retail_sales
WHERE transactions_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	AGE IS NULL
	OR 
	CATEGORY IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
	
-- Deleting the data with null values

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	AGE IS NULL
	OR 
	CATEGORY IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--- Data Exploration

-- How many sales we have?

SELECT COUNT(*) as total_sales FROM retail_sales;

-- How many unique customers we have?

SELECT COUNT(DISTINCT customer_id) as total_sales FROM retail_sales;

-- How many unique categories we have?

SELECT COUNT(DISTINCT category) as total_sales FROM retail_sales;

-- What are the categories?

SELECT DISTINCT category FROM retail_sales;

--- Data Analysis & Business Key Problems & Answers


-- My Analysis & Findings

-- Q1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'.

SELECT * FROM retail_sales
WHERE
	sale_date = '2022-11-05';

-- Q2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is 4 or more in the month of Nov-2022.

SELECT * FROM retail_sales
WHERE 
	category = 'Clothing'
	AND 
	TO_CHAR(sale_date, 'YYYY, MM') = '2022, 11'
	AND
	quantity >= 4;

-- Q3 Write a SQL query to calculate the total sales for each category.

SELECT
	category,
	SUM(total_sale) as net_sales,
	COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1;

-- Q4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
	ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE  category = 'Beauty';

-- Q5 Write a SQL query to find all transactions where the total sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q6 Write a SQL query to find the total number of transactions made by each gender in each category.

SELECT
	category,
	gender,
	COUNT(*) as total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY 1;

-- Q7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.

SELECT 
	year,
	month,
	avg_sale
FROM
(
	SELECT
		EXTRACT (YEAR FROM sale_date) as year,
		EXTRACT (MONTH FROM sale_date) as month,
		AVG(total_sale) as avg_sale,
		RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
	FROM retail_sales
	GROUP BY 1, 2
) as t1
WHERE rank = 1;

-- Q8 Write a SQL query to find the top 5 customers based on the highest total sales.

SELECT
	customer_id,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q9 Write a SQL query to find the number of unique customers who purhcased items from each category.

SELECT
	category,
	COUNT(DISTINCT customer_id) as count_of_unique_customer
FROM retail_sales
GROUP BY 1;

-- Q10 Write a SQL query to create each shift and number of orders (Example Morning < 12, Afternoon Between 12 & 17, Evening > 17).

WITH hourly_sales
AS
(
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales
)
SELECT 
	shift,
	COUNT(*) as total_orders
FROM hourly_sales
GROUP BY 1;

-- Q11 Which category generates the highest profit?

SELECT
	category,
	ROUND(SUM(total_sale - cogs):: numeric, 2) as net_profit
FROM retail_sales
GROUP BY 1;

-- Q12 Who are the top 5 most profitable customers?

SELECT
	customer_id,
	ROUND(SUM(total_sale - cogs):: numeric, 2) as net_profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q13 Which category has the highest average profit per transaction?

SELECT
	category,
	ROUND(AVG(total_sale - cogs):: numeric, 2) as net_profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- Q14 What percentage of total sales comes from each category?

SELECT
	category,
	ROUND(
			(category_sales / SUM(category_sales) OVER() * 100):: numeric,
			2) 
			as sale_percentage
FROM
(
	SELECT
		category,
		SUM(total_sale) as category_sales
	FROM retail_sales
	GROUP BY 1
) as t3;

-- Q15 Which customers are repeat customers?

SELECT
	customer_id
FROM
(
	SELECT
		customer_id,
		COUNT(*) as num_of_purchases
	FROM retail_sales
	GROUP BY 1
)
WHERE num_of_purchases > 1;

-- Q16 What percentage of customers are repeat customers?

SELECT
ROUND(
			 (repeat_count::numeric / total_customers * 100),
			2) 
			as sale_percentage
FROM
(
	SELECT
		COUNT(customer_id) as repeat_count,
		(SELECT COUNT(DISTINCT customer_id)
         FROM retail_sales) as total_customers
	FROM
	(
		SELECT
			customer_id,
			COUNT(*) as num_of_purchases
		FROM retail_sales
		GROUP BY 1
	)
	WHERE num_of_purchases > 1
) as percentage_repeat_customers;

-- Q17 Which day of the week generates the most revenue?

SELECT
	TO_CHAR(sale_date, 'Day') as day,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;
	

-- Q18 How has monthly revenue changed over time?

SELECT
    month,
    total_sales,
    previous_month_sales,
    ROUND(
        ((total_sales - previous_month_sales) / previous_month_sales * 100)::numeric,
        2
    ) as monthly_percentage_change
FROM
(
    SELECT
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) as previous_month_sales
    FROM
    (
        SELECT
            TO_CHAR(sale_date, 'YYYY-MM') as month,
            SUM(total_sale) as total_sales
        FROM retail_sales
        GROUP BY 1
    ) as monthly_sales
) as monthly_comparison;
