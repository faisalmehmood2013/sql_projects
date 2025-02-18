SELECT * FROM ecommerce.customers;

## Q # 1: How many unique cities do the customers come from?
SELECT 
    COUNT(DISTINCT customer_city)
FROM
    customers;

## Q # 2: How many customers are in each city?
SELECT DISTINCT
    customer_city, COUNT(customer_city) total_customers
FROM
    customers
GROUP BY customer_city
ORDER BY total_customers DESC;

## Q # 3: How many unique states do the customers come from?
select count(distinct customer_state) from customers;

## Q # 4: Which 10 states have the highest number of customers?
SELECT 
    customer_state, COUNT(customer_state) total_customer
FROM
    customers
GROUP BY customer_state
ORDER BY total_customer DESC
LIMIT 10;

## Q # 4:
with count_per_order as (select orders.order_id, orders.customer_id, count(order_items.order_id) as oc
from orders join order_items
on orders.order_id = order_items.order_id
group by orders.order_id, orders.customer_id)

select customers.customer_city, round(avg(count_per_order.oc),2) average_orders
from customers join count_per_order
on customers.customer_id = count_per_order.customer_id
group by customers.customer_city order by average_orders desc;

## Q # 5: What percentage of customers placed a new order after their first order, but only after 6 months from their first purchase?
with a as (select customers.customer_id, min(orders.order_purchase_timestamp) first_order from customers join orders on customers.customer_id = orders.customer_id group by customers.customer_id),
b as (select a.customer_id, count(distinct orders.order_purchase_timestamp) second_order from a join orders on a.customer_id = orders.customer_id and orders.order_purchase_timestamp > first_order and orders.order_purchase_timestamp > date_add(first_order, interval 6 month) group by a.customer_id)
select count(distinct a.customer_id) / count(distinct b.customer_id) * 100 as 06_month_new_order from a left join b on a.customer_id = b.customer_id;