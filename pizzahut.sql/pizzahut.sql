-- BASIC
use pizzahut;

-- BASIC ANALYSIS
-- 1) Total Orders Count
-- Find the total number of orders placed.
USE PIZZAHUT;
select count(order_id)
from orders;

-- 2) Revenue Calculation
-- Calculate the total revenue from pizza sales.

select 
    sum(quantity*price)
from order_details as od join pizzas as p
on od.pizza_id=p.pizza_id;

-- 3) Most Expensive Pizza
-- Identify the Highest-priced pizza.

select
    max(price)
from pizzas;

-- 4) Most Ordered Pizza Size
-- Determine the most frequently Ordered pizza size

SELECT 
    p.size,
    SUM(od.quantity) AS total_ordered
FROM order_details as od JOIN pizzas as p 
ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC
LIMIT 1;

-- 5) Top 5 Popular Pizzas
-- List the top 5 pizzas by order quantity

select * from pizzas;
SELECT 
    pt.name AS pizza_name,
    SUM(od.quantity) AS tq
FROM order_details as od
JOIN pizzas as p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types as pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY tq DESC
LIMIT 5;

-- INTERMEDIATE
-- PIZZA QUNTITY BY ORDER
SELECT
    pt.category,
    SUM(od.quantity) AS tq_ord 
FROM pizzas AS p JOIN pizza_types AS pt 
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od 
ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY tq_ord; 
-- -- 2) Order Trends by Hour
-- Analyze the distribution of orders by hour of day.
select * from orders;

SELECT 
    HOUR(time) AS order_hour,
    COUNT(*) AS t_o
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- 3) Pizza Distribution by Category
-- Determine the order distribution of pizzas by category

SELECT 
    pt.category AS pizza_category,
    COUNT(od.pizza_id) AS total_orders
FROM order_details AS od JOIN pizzas AS p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
    pt.category
ORDER BY 
    total_orders DESC;
    
    -- 4) Average Daily Pizza Orders
-- Calculate the average number of pizzas ordered each day

SELECT 
    DATE(o.order_id) AS order_date,
    AVG(od.quantity) AS average_pizzas_ordered
FROM orders AS o JOIN order_details AS od 
ON o.order_id = od.order_id
GROUP BY 
    order_date
ORDER BY 
    order_date;
    
    -- 5) Top Pizza Types by Revenue
-- Identify the top 3 pizzas based on revenue

select * from pizzas;

SELECT 
    p.pizza_id,
    SUM(od.quantity * p.price) AS total_revenue
FROM order_details AS od JOIN pizzas AS p 
ON od.pizza_id = p.pizza_id
GROUP BY 
    p.pizza_id
ORDER BY 
    total_revenue DESC
LIMIT 3;

-- ADVANCED

use pizzahut;

-- 1) Revenue Contribution by Pizza Type
-- Calculate each pizza type’s percentage contribution to total revenue


WITH TotalRevenue AS (
    SELECT 
        SUM(od.quantity * p.price) AS total_revenue
    FROM order_details AS od
    JOIN pizzas AS p 
    ON od.pizza_id = p.pizza_id
),
PizzaRevenue AS (
    SELECT 
        pt.category AS pizza_type,
        SUM(od.quantity * p.price) AS type_revenue
    FROM order_details AS od JOIN pizzas AS p 
    ON od.pizza_id = p.pizza_id
    JOIN pizza_types AS pt 
    ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY 
        pt.category
)
SELECT 
    pr.pizza_type,
    pr.type_revenue,
    (pr.type_revenue / tr.total_revenue) * 100 AS percentage_contribution
FROM 
    PizzaRevenue AS pr,
    TotalRevenue AS tr
ORDER BY 
    percentage_contribution DESC;
    
-- 2) Cumulative Revenue Over Time
-- Track cumulative revenue growth over time

WITH RevenuePerOrder AS (
    SELECT 
        DATE(o.date) AS order_date,  -- Using 'o.date' for the order date
        SUM(od.quantity * p.price) AS order_revenue
    FROM orders AS o JOIN order_details AS od 
    ON o.order_id = od.order_id
    JOIN pizzas AS p 
    ON od.pizza_id = p.pizza_id
    GROUP BY order_date
)
SELECT 
    order_date,
    order_revenue,
    SUM(order_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM RevenuePerOrder
ORDER BY order_date;

-- 3) Top 3 Pizza Types by Revenue in Each Category
-- Determine the top 3 pizzas by revenue within each category

WITH PizzaRevenue AS (
    SELECT 
        pt.name AS pizza_category,
        p.pizza_id,
        p.size,
        SUM(od.quantity * p.price) AS total_revenue
    FROM order_details AS od
    JOIN pizzas AS p 
    ON od.pizza_id = p.pizza_id
    JOIN pizza_types AS pt 
    ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name, p.pizza_id, p.size
),
RankedPizzas AS (
    SELECT 
        pizza_category,
        pizza_id,
        size,
        total_revenue,
	RANK() OVER (PARTITION BY pizza_category ORDER BY total_revenue DESC) AS revenue_rank
    FROM PizzaRevenue
)
SELECT 
    pizza_category,
    pizza_id,
    size,
    total_revenue
FROM RankedPizzas
WHERE revenue_rank <= 3
ORDER BY pizza_category, total_revenue DESC;

