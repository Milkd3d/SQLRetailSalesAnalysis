# Retail Sales Analysis SQL Project

## Project Overview

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sqlProject`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE sqlProject;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

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

```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05'**:
```sql
SELECT * FROM retail_sales
WHERE
	sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is 4 or more in the month of Nov-2022**:
```sql
SELECT * FROM retail_sales
WHERE 
	category = 'Clothing'
	AND 
	TO_CHAR(sale_date, 'YYYY, MM') = '2022, 11'
	AND
	quantity >= 4;
```

3. **Write a SQL query to calculate the total sales for each category.**:
```sql
SELECT
	category,
	SUM(total_sale) as net_sales,
	COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT
	ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE  category = 'Beauty';
```

5. **Write a SQL query to find all transactions where the total sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000;
```

6. **Write a SQL query to find the total number of transactions made by each gender in each category.**:
```sql
SELECT
	category,
	gender,
	COUNT(*) as total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY 1;
```

7. **Find the month with the highest average sale in each year.**:
```sql
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
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales**:
```sql
SELECT
	customer_id,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT
	category,
	COUNT(DISTINCT customer_id) as count_of_unique_customer
FROM retail_sales
GROUP BY 1;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning < 12, Afternoon Between 12 & 17, Evening > 17)**:
```sql
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
```

11. **Which category generates the highest profit?**:
```sql
SELECT
	category,
	ROUND(SUM(total_sale - cogs):: numeric, 2) as net_profit
FROM retail_sales
GROUP BY 1
ORDER BY net_profit DESC
LIMIT 1;
```

12. **Who are the top 5 most profitable customers?**:
```sql
SELECT
	customer_id,
	ROUND(SUM(total_sale - cogs):: numeric, 2) as net_profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

13. **Which category has the highest average profit per transaction?**:
```sql
SELECT
	category,
	ROUND(AVG(total_sale - cogs):: numeric, 2) as net_profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

14. **What percentage of total sales comes from each category?**:
```sql
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
```

15. **Which customers are repeat customers?**:
```sql
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
```

16. **What percentage of customers are repeat customers?**:
```sql
SELECT
ROUND(
			 (repeat_count::numeric / total_customers * 100),
			2) 
			as repeat_customer_percentage
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
	) as customer_purchases
	WHERE num_of_purchases > 1
) as percentage_repeat_customers;
```

17. **Which day of the week generates the most revenue?**:
```sql
SELECT
	TO_CHAR(sale_date, 'Day') as day,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;
```

18. **How has monthly revenue changed over time?**:
```sql
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
```

## SQL Concepts Demonstrated

* `SELECT`, `WHERE`, `ORDER BY`, and `GROUP BY`
* Aggregate functions: `COUNT`, `SUM`, `AVG`
* `DISTINCT`
* Subqueries and nested queries
* Common Table Expressions (`WITH`)
* `CASE` statements
* Date/time functions with `EXTRACT()` and `TO_CHAR()`
* Window functions with `RANK()` and `LAG()`
* `COUNT(DISTINCT ...)`
* Percentage and profit calculations
* Data cleaning and NULL handling
* Type casting and numeric rounding

## Conclusion

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
