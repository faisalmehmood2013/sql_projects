SELECT * FROM ecommerce.orders;
select distinct order_status from orders;

## 1. How many orders were placed in the year 2018?
SELECT 
    YEAR(order_purchase_timestamp) AS year,
    COUNT(order_status) AS total_order
FROM
    orders
GROUP BY year
HAVING year = 2018
ORDER BY total_order DESC; 

## 2. How many orders were placed each year?
SELECT 
    YEAR(order_purchase_timestamp) AS year,
    COUNT(order_status) AS total_order
FROM
    orders
GROUP BY year
ORDER BY total_order DESC;

## 3. How many orders were placed in each status in the year 2017?
SELECT DISTINCT
    order_status,
    COUNT(order_status) total_order,
    YEAR(order_purchase_timestamp) year
FROM
    orders
GROUP BY order_status , year
HAVING year = 2017
ORDER BY total_order DESC; 

## 4. How many orders were delivered each year?
SELECT DISTINCT
    YEAR(order_purchase_timestamp) AS year,
    COUNT(order_status) AS total_order,
    order_status
FROM
    orders
GROUP BY year , order_status
HAVING order_status = 'delivered'
ORDER BY total_order DESC;

## 5. How many orders were placed in each month of the year 2018?
SELECT 
    MONTHNAME(order_purchase_timestamp) months,
    COUNT(order_id) orders
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2018
GROUP BY months;

## 6. Which city has the highest average number of items per order? 
with total_order_count as (select orders.order_id, orders.customer_id, count(order_items.order_id) as order_count from orders join order_items on orders.order_id = order_items.order_id group by orders.order_id, orders.customer_id)
select customers.customer_city, round(avg(total_order_count.order_count), 1) as average_count from customers join total_order_count on customers.customer_id = total_order_count.customer_id group by customers.customer_city order by average_count desc;

## 7. What is the 4-period moving average of payment values for each customer, ordered by purchase timestamp?
select customer_id, time_stamp, payment,  round(avg(payment) over (partition by customer_id order by time_stamp rows between 3 preceding and current row),2) moving_average from
(SELECT 
    orders.customer_id customer_id,
    orders.order_purchase_timestamp time_stamp,
    payments.payment_value payment
FROM
    orders
        JOIN
    payments ON orders.order_id = payments.order_id) as a;
    
## 8. What is the monthly sales amount for each year, along with the running cumulative total of sales over time?
select year, month, payment_value, round(sum(payment_value) over (order by year, month), 2) Cumulative_sales from
(select year(orders.order_purchase_timestamp) as year, month(orders.order_purchase_timestamp) as month, round(sum(payments.payment_value), 2) payment_value from orders join payments on orders.order_id = payments.order_id group by year, month order by year, month) as a;

## 9. What is the total sales for each year along with the running cumulative sales over the years? 
select year, payment_value, round(sum(payment_value) over (order by year), 2) Cumulative_sales from
(select year(orders.order_purchase_timestamp) as year, round(sum(payments.payment_value), 2) payment_value from orders join payments on orders.order_id = payments.order_id group by year order by year) as a;

## 10. What is the yearly sales, cumulative sales over the years, and the year-over-year (YoY) growth rate in sales? 
select year, payment_value, round(sum(payment_value) over (order by year), 2) Cumulative_sales, round((payment_value - lag(payment_value, 1) over(order by year))/
lag(payment_value, 1) over(order by year) * 100, 2) yoy_growth_rate from
(select year(orders.order_purchase_timestamp) as year, round(sum(payments.payment_value), 2) payment_value from orders join payments on orders.order_id = payments.order_id group by year order by year) as a;

## 11. What are the monthly sales, cumulative sales over time, and the month-over-month growth rate in sales?
select year, month, payment_value, round(sum(payment_value) over (order by year, month), 2) Cumulative_sales, round((payment_value - lag(payment_value, 1) over(order by year, month))/
lag(payment_value, 1) over(order by year, month) * 100, 2) yoy_growth_rate from
(select year(orders.order_purchase_timestamp) as year, month(orders.order_purchase_timestamp) as month, round(sum(payments.payment_value), 2) payment_value from orders join payments on orders.order_id = payments.order_id group by year, month order by year, month) as a;


## 12. selects those customers who are among the top three highest spenders each year? 
with a as (select year(orders.order_purchase_timestamp) year, orders.customer_id customer_id, sum(payments.payment_value) payment
from orders join payments on orders.order_id = payments.order_id group by year, customer_id),
b as (select a.year, a.customer_id, a.payment, dense_rank() over (partition by year order by payment desc) d_rank from a)
select * from b where d_rank <= 3;																