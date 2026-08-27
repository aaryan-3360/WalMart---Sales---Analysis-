create database walmartSales;
use walmartSales;
select * from sales;
drop table sales;
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-- Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening.

select time,
(case 
when `time` between "00:00:00" and "12:00:00" then "Morning"
when `time` between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end ) as time_of_day 
from sales;

ALTER TABLE sales add COLUMN time_of_day varchar(30) ;

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
alter table sales add column day_name varchar(30);

select date,dayname(date) from sales;
update sales set day_name =dayname(date);


-- Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
alter table sales add column month_name varchar(30);

select date,monthname(date) from sales;
update sales set month_name = monthname(date);

-- Generic Question

-- 1.How many unique cities does the data have?
select count(distinct city) from sales; 

-- 2.In which city is each branch?
select distinct branch,city from sales; 

select distinct city from sales where branch in ("A","B","C");


-- Product
-- 1.How many unique product lines does the data have?
select count(distinct sales.product_line) from sales;

-- 2.What is the most common payment method?
SELECT 
    payment, COUNT(*)
FROM
    sales
GROUP BY payment
ORDER BY 2 DESC
LIMIT 1;

-- 3.What is the most selling product line?
select product_line, sum(quantity) as most_selling
from sales 
group by 1
order by 2 desc
limit 1;

-- 4. What is the total revenue by month?
select month_name,sum(total) as revenue
from sales
group by month_name
order by month_name;

-- 5.Which month had the largest COGS?
select month_name,sum(cogs) as largest_cogs
from sales
group by month_name
order by 2 desc 
limit 1;

-- 6.What product line had the largest revenue?
select product_line,sum(total) as largest_revenue
from sales
group by product_line
order by 2 desc 
limit 1;

-- 7.What is the city with the largest revenue?
select city,sum(total) as largest_revenue
from sales
group by 1
order by 2 desc
limit 1;

-- 8.What product line had the largest VAT?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC
limit 1;

-- 9.Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select avg(quantity) as avg_quantity
from sales;

select product_line ,
( case 
when avg(quantity) > 6 then "Good"
else "Bad"
end
 ) as Performance
from sales
group by product_line;


-- 10.Which branch sold more products than average product sold?
select branch,sum(quantity) as total_product_sold
from sales 
group by branch
having  sum(quantity)> (Select avg(quantity) from sales);

-- 11.What is the most common product line by gender
SELECT gender, product_line, total
FROM (
    SELECT
        gender,
        product_line,
        COUNT(*) AS total,
        RANK() OVER (
            PARTITION BY gender
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM sales
    GROUP BY gender, product_line
) AS rnk
WHERE rnk = 1;

-- 12.What is the average rating of each product line
select product_line,avg(rating) as average_rating
from sales
group by product_line
order by 2 desc;

-- -------------------------- Customers -------------------------------

-- 13.How many unique customer types does the data have?
select count( distinct customer_type) as total_type from sales;

-- 14.How many unique payment methods does the data have?
select count(distinct payment) as payment_method from sales;

-- 15.What is the most common customer type?
 SELECT
    customer_type,
    COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC
LIMIT 1;

-- 16.Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type
order by 2 desc 
limit 1;


-- 17.What is the gender of most of the customers?
select gender , count(*) as count
from sales
group by gender
order by 2 desc
limit 1;

-- 18.What is the gender distribution per branch
SELECT
    branch,
    gender,
    COUNT(*) AS count
FROM sales
GROUP BY branch, gender
ORDER BY branch, count DESC;

-- 19.Which time of the day do customers give most ratings?
select time_of_day , avg(rating) as avg_rating
from sales
group by 1 
order by avg_rating desc
limit 1;

-- 20.Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, avg_rating
FROM (
    SELECT
        branch,
        time_of_day,
        AVG(rating) AS avg_rating,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY AVG(rating) DESC
        ) AS rnk
    FROM sales
    GROUP BY branch, time_of_day
) AS ranked
WHERE rnk = 1;

-- 21.Which day of the week has the best avg ratings?
select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by 2 desc 
limit 1; 

-- 22.Which day of the week has the best average ratings per branch?
SELECT branch, day_name, avg_rating
FROM (
    SELECT
        branch,
        day_name,
        AVG(rating) AS avg_rating,
        RANK() OVER (
            PARTITION BY branch
            ORDER BY AVG(rating) DESC
        ) AS rnk
    FROM sales
    GROUP BY branch, day_name
) AS ranked
WHERE rnk = 1;



-- ---------------------------- Sales ---------------------------------

-- 23.Number of sales made in each time of the day per weekday 
SELECT
    day_name,
    time_of_day,
    COUNT(*) AS total_sales
FROM sales
GROUP BY day_name, time_of_day
ORDER BY
    FIELD(day_name, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    time_of_day;

-- 24.Which of the customer types brings the most revenue?
SELECT 
    customer_type,
    SUM(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC
LIMIT 1;

-- 25.Which city has the largest tax/VAT percent?
SELECT
    city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city
ORDER BY avg_tax_pct DESC
LIMIT 1;

-- 26.Which customer type pays the most in VAT?
SELECT
    customer_type,
    AVG(tax_pct) AS avg_tax
FROM sales
GROUP BY customer_type
ORDER BY avg_tax DESC
LIMIT 1;





