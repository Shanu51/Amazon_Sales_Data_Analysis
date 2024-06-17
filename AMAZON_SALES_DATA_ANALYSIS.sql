# creted DB and imported the dataset.
# Data Wrangling: 
-- column count: -- there are 20 columns.
SELECT count(*)
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'amazon'
AND TABLE_NAME = 'amazon';

-- to check null value: -- There is no null value or missing data in dataset.
SELECT
    COUNT(CASE WHEN `Unit price` IS NULL THEN 1 END) AS `Unit price_nulls`,
    COUNT(CASE WHEN `Total` IS NULL THEN 1 END) AS `Total_nulls`,
    COUNT(CASE WHEN `time_of_day` IS NULL THEN 1 END) AS `time_of_day_nulls`,
    COUNT(CASE WHEN `Time` IS NULL THEN 1 END) AS `Time_nulls`,
    COUNT(CASE WHEN `Tax 5%` IS NULL THEN 1 END) AS `Tax 5%_nulls`,
    COUNT(CASE WHEN `Rating` IS NULL THEN 1 END) AS `Rating_nulls`,
    COUNT(CASE WHEN `Quantity` IS NULL THEN 1 END) AS `Quantity_nulls`,
    COUNT(CASE WHEN `Product line` IS NULL THEN 1 END) AS `Product line_nulls`,
    COUNT(CASE WHEN `Payment` IS NULL THEN 1 END) AS `Payment_nulls`,
    COUNT(CASE WHEN `month_name` IS NULL THEN 1 END) AS `month_name_nulls`,
    COUNT(CASE WHEN `Invoice ID` IS NULL THEN 1 END) AS `Invoice ID_nulls`,
    COUNT(CASE WHEN `gross margin percentage` IS NULL THEN 1 END) AS `gross margin percentage_nulls`,
    COUNT(CASE WHEN `gross income` IS NULL THEN 1 END) AS `gross income_nulls`,
    COUNT(CASE WHEN `Gender` IS NULL THEN 1 END) AS `Gender_nulls`,
    COUNT(CASE WHEN `day_name` IS NULL THEN 1 END) AS `day_name_nulls`,
    COUNT(CASE WHEN `Date` IS NULL THEN 1 END) AS `Date_nulls`,
    COUNT(CASE WHEN `Customer type` IS NULL THEN 1 END) AS `Customer type_nulls`,
    COUNT(CASE WHEN `cogs` IS NULL THEN 1 END) AS `cogs_nulls`,
    COUNT(CASE WHEN `City` IS NULL THEN 1 END) AS `City_nulls`,
    COUNT(CASE WHEN `Branch` IS NULL THEN 1 END) AS `Branch_nulls`
FROM
    amazon;

-- to understand the data type of dataset.
 desc amazon;

-- Altered column date to cahnge the format oF date column from text to date .
alter table amazon modify column date date;

# Feature Engineering: 
-- Adding a new column time_of_day to give insight of sales in the Morning, Afternoon and Evening.

ALTER TABLE AMAZON ADD COLUMN TIME_OF_DAY VARCHAR(20);

UPDATE amazon
 SET time_of_day = (
	CASE
 		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
      WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
     END
 );
-- Adding a new column named day_name that contains the extracted days of the week.

ALTER TABLE AMAZON ADD COLUMN DAY_NAME VARCHAR(20);

UPDATE AMAZON 
SET DAY_NAME =(DAYNAME(DATE)); 

-- Add a new column named month_name.
ALTER TABLE AMAZON ADD COLUMN month_name VARCHAR(20);
UPDATE AMAZON 
SET MONTH_NAME =MONTHNAME(DATE);
SELECT * FROM AMAZON ;

SELECT DATE,MONTHNAME(DATE) FROM AMAZON;

-- ----------------------------------
select count(*) from amazon;

-- -------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------
# BUSINESS QUESTIONS TO ANSWER:

-- # 1.What is the count of distinct cities in the dataset?
select distinct city from amazon;
# city:
-- 'Yangon'
-- 'Naypyitaw'
-- 'Mandalay'  are the distinct cities.
-- ---------------------------------------------------

# 2.For each branch, what is the corresponding city?
select distinct branch,city from amazon; 
# branch, city
-- 'A', 'Yangon'
-- 'C', 'Naypyitaw'
-- 'B', 'Mandalay'   these are the corresponding city according to branch.
-- ------------------------------------------------------------------------

# 3.What is the count of distinct product lines in the dataset?
select count(distinct `product line`) from amazon;
-- Ans:- 6  there are distinct product lines in the dataset.
-- -------------------------------------------------------------------------

# 4.Which payment method occurs most frequently?
select payment,count(payment) cnt from amazon group by payment order by cnt desc limit 1;
#   payment, cnt
-- 'Ewallet', '345' Here most frequenty method is Ewallet.
--  Here we can say most of the customers prefer to pay through ewallet.
-- -------------------------------------------------------------------------

# 5.Which product line has the highest sales?
select `product line`,sum(quantity) qty from amazon group by `product line` order by qty desc limit 1;
# product line, qty
-- 'Electronic accessories', '971' Here Electronic accessories has the higest sale.
-- ---------------------------------------------------------------------------------

# 6.How much revenue is generated each month?
select month_name,ROUND(sum(total),2)rev from amazon group by month_name;
# month_name, rev
-- 'January', '116291.86800000005'
-- 'March', '109455.50700000004'
-- 'February', '97219.37399999997'
-- -----------------------------------------------------------------
# 7.In which month did the cost of goods sold reach its peak?
select round(sum(cogs),2) cogs, month_name from amazon group by month_name order by cogs desc limit 1;
# cogs, month_name
-- '110754.16', 'January' reach its peak.
-- ------------------------------------------------------------

# 8.Which product line generated the highest revenue?
select `product line`,sum(total) rev from amazon group by `product line` order by rev desc limit 1;
-- Ans:-Food and beverages generated the highest revenue.
-- --------------------------------------------------------------

# 9.In which city was the highest revenue recorded?
select city,ROUND(sum(total),2) rev from amazon group by city order by rev desc limit 1;
-- Ans:Naypyitaw was the highest revenue recorded.
-- ------------------------------------------------------------------

# 10.Which product line incurred the highest Value Added Tax?
select `product line` ,ROUND(sum(`Tax 5%`),2)*(1/100) rev from amazon group by `product line` order by sum(`Tax 5%`) desc limit 1;
-- Ans: 'Food and beverages', '2673.5639999999994' incurred the highest Value Added Tax.
-- -----------------------------------------------------------------------------------------------

# 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT
    `product line`,
     (SELECT AVG(quantity) FROM amazon) avg_sale_of_all_prod_line,
    AVG(quantity)avg_sale_of_perticular_prod_line,
    CASE
        WHEN AVG(quantity) > (SELECT AVG(quantity) FROM amazon) THEN "Good"
        ELSE "Bad"
    END AS remark
FROM
    amazon
GROUP BY
    `product line`;
-- ----------------------------------------------------------------------------------------   

# 12.Identify the branch that exceeded the average number of products sold.

  SELECT branch,avg(Quantity) avg_qty
        FROM amazon group by branch having avg(quantity)>(select avg(Quantity) from amazon) order by avg_qty desc;
-- ---------------------------------------------------------------------
# 13.Which product line is most frequently associated with each gender?

select gender, `product line`, freq as most_freq
from (select gender, `product line`, count(*) as freq, 
row_number () over (partition by gender order by count(*) desc) as row_num 
 from amazon 
 group by gender, `product line`) as temp_data
 where row_num=1; 
 
-- here we can say females are generaly preferd to order Fashion accessories product line and men prefered Health and beauty.
-- -----------------------------------------------------

-- -------------------------------------------------

# 14.Calculate the average rating for each product line.
select `Product line`,round(avg(rating),2) avg_rating from amazon group by `Product line` order by avg_rating desc;
-- -------------------------------------------------------------------------------

# 15.Count the sales occurrences for each time of day on every weekday.
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM amazon
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Here we can say prefers to order during the evening hours.
-- --------------------------------------------------------

# 16.Identify the customer type contributing the highest revenue.
SELECT
	`Customer type`,
	sum(total) AS total_revenue
FROM amazon
GROUP BY `Customer type`
ORDER BY total_revenue desc ;
-- Here members are contributing the highest revenue.
-- -------------------------------------------------------------

# 17.Determine the city with the highest VAT percentage.
select city,round(avg(`Tax 5%`),2) vat from amazon group by city order by vat desc; 
-- Naypyitaw has the highest VAT percentage.
-- ----------------------------------------------------------------------

# 18.Identify the customer type with the highest VAT payments.
select `Customer type`,round(avg(`Tax 5%`),2) vat from amazon group by `Customer type` order by vat desc; 
-- members are the highest VAT payers.
-- ---------------------------------------------------------------------

# 19.What is the count of distinct customer types in the dataset?
select `Customer type`,count(distinct `Customer type`)cust_type from amazon group by `Customer type`;
-- There are two types of customer.
-- ----------------------------------------------------------------------

# 20.What is the count of distinct payment methods in the dataset?
select distinct payment from amazon group by payment;
-- there are 3 payment methods ewallet,cash,credit card.
-- ---------------------------------------------------------

# 21.Which customer type occurs most frequently?
select `Customer type`,count(`Customer type`)cust_type from amazon  group by `Customer type` order by cust_type desc limit 1;
-- the members are the most frequent customers.
-- --------------------------------------------------------------

# 22.Identify the customer type with the highest purchase frequency.
select `Customer type`,count(*)cnt from amazon group by `Customer type` order by cnt desc limit 1;
-- the members has the highest purchase frequency.
-- ------------------------------------------------------------

# 23.Determine the predominant gender among customers.
select gender, count(*)cnt from amazon group by gender order by cnt desc limit 1;
-- females are MOST FREQUENT ORDERD THE PRODUCT.
-- ------------------------------------------------------------

# 24.Examine the distribution of genders within each branch.
select branch,
	SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS Male_Count,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS Female_Count
	from amazon group by branch;
-- -----------------------------------------------------------------------      

# 25.Identify the time of day when customers provide the most ratings.
select time_of_day,round(avg(rating),2)rating from amazon group by time_of_day limit 1;
-- customer provide the most ratings at 'Afternoon'. 
-- -----------------------------------------------------------------------

# 26.Determine the time of day with the highest customer ratings for each branch.

select branch,time_of_day,rating
from
(select branch,time_of_day,round(avg(rating),2)rating,row_number() over(partition by branch order by round(avg(rating),2) desc)row_num 
from amazon 
group by branch,time_of_day) sq
where row_num=1;
-- ------------------------------------------------------------------------------------------------------------------

# 27.Identify the day of the week with the highest average ratings.
select day_name,round(avg(rating),2)rating from amazon group by day_name order by Rating desc;-- limit 1;
-- Mon and Friday are the top best days for good ratings.
-- -----------------------------------------------------------------------------------------------

# 28.Determine the day of the week with the highest average ratings for each branch.

SELECT branch, day_name,avg_rating
FROM (
    SELECT branch, day_name, ROUND(AVG(rating), 2) AS avg_rating,
           ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS avg_rating_rank
    FROM amazon
    GROUP BY branch, day_name
) AS subquery
WHERE avg_rating_rank = 1 order by avg_rating desc;









