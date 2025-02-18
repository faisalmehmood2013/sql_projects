SELECT * FROM ecommerce.products;

## 1. What are the top 5 product categories with the highest sales?
SELECT 
    UPPER(products.product_category) AS category,
    ROUND(SUM(payments.payment_value), 2) AS sales
FROM
    products
        JOIN
    order_items ON products.product_id = order_items.product_id
        JOIN
    payments ON order_items.order_id = payments.order_id
GROUP BY category
ORDER BY sales DESC
LIMIT 5;

## 2. Which product category had the most orders in 2018?
SELECT 
    category
FROM
    (SELECT 
        UPPER(products.product_category) AS category,
            COUNT(orders.order_id) total_orders_2018
    FROM
        products
    JOIN order_items ON products.product_id = order_items.product_id
    JOIN orders ON order_items.order_id = orders.order_id
    WHERE
        orders.order_purchase_timestamp = 2018
    GROUP BY category
    ORDER BY total_orders_2018 DESC
    LIMIT 1) AS a;
    
## 3. What is the sales percentage distribution of the top 10 product categories?
with sales as (SELECT 
    UPPER(products.product_category) AS category,
    ROUND(SUM(payments.payment_value), 2) AS sales
FROM
    products
        JOIN
    order_items ON products.product_id = order_items.product_id
        JOIN
    payments ON order_items.order_id = payments.order_id
GROUP BY category
ORDER BY sales DESC limit 10),

total_sales as (select sum(payments.payment_value) as total_sales from payments)
select sales.category, sales.sales, round((sales.sales/total_sales.total_sales) * 100,2) percentage_distribution from sales, total_sales; 

## 4. What is the average price and order count for each product category?
select products.product_category category,
count(order_items.product_id) order_count,
round(avg(order_items.price),2) average_price
from products join order_items
on products.product_id = order_items.product_id
group by products.product_category;