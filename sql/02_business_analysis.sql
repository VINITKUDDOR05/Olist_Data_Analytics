/*
====================================================
OLIST E-COMMERCE DATA ANALYSIS
Business Analysis using PostgreSQL
====================================================

TASK 1: Order Status Distribution
Business Question:
What is the total number of orders under each order status?

TASK 2: Monthly Order Trends
Business Question:
How many orders were placed each month?

TASK 3: Delivered Product Revenue
Business Question:
What is the total product revenue and freight value
generated from delivered orders?

TASK 4: Top 10 Product Categories
Business Question:
Which are the top 10 product categories
based on total product revenue?

TASK 5: Customer Review Analysis
Business Question:
What is the average customer review score
and how many reviews were received?

TASK 6: Repeat Customer Analysis
Business Question:
How many customers placed more than one order?

TASK 7: Top 10 Customer Cities
Business Question:
Which 10 cities have the highest number
of customer records?

TASK 8: Average Order Value (AOV)
Business Question:
What is the average product value per order?

TASK 9: Monthly Revenue Analysis
Business Question:
How much product revenue was generated
from delivered orders each month?

TASK 10: Delivery Performance Analysis
Business Question:

Q1: What is the average delivery time in days?

Q2: How many orders were delivered on time
and how many were delivered late?

Q3: What percentage of delivered orders
reached customers on or before the estimated date?

TASK 11: PAYMENT ANALYSIS

Q1. Which payment methods generate the highest
    total payment value?

Q2. What is the average payment value
    for each payment method?

Q3. How do payment installments affect
    the average payment value?


TASK 12: SELLER PERFORMANCE ANALYSIS

Q1. Who are the top 10 sellers by product revenue?

Q2. What is the average order value
    for each seller?

Q3. Which Brazilian states generate
    the highest seller revenue?

====================================================
*/

--Analysis 1 — Order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

--Analysis 2 — Monthly order trends

SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
    COUNT(*) AS total_orders
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY order_month;

--Analysis 3 — Total sales revenue

SELECT
    ROUND(SUM(oi.price), 2) AS total_product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_value
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

--Analysis 4 — Top 10 product categories

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category_name,

    ROUND(SUM(oi.price), 2) AS total_revenue

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation t
    ON p.product_category_name = t.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY category_name
ORDER BY total_revenue DESC
LIMIT 10;

--Analysis 5 — Average customer review score

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score,
    COUNT(*) AS total_reviews
FROM order_reviews
WHERE review_score IS NOT NULL;

--Task 1: Identify repeat customers

SELECT
    customer_unique_id,
    COUNT(*) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;

--repeat customers

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(*) > 1
) AS repeat_customer_list;

--Task 2: Top 10 customer cities

SELECT
    customer_city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;

--Task 3: Average Order Value (AOV)

SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(price) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_values;

--Task 4: Monthly revenue trend

SELECT
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

--Task 5: Average delivery time

SELECT
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                order_delivered_customer_date -
                order_purchase_timestamp
            )) / 86400
        ),
        2
    ) AS avg_delivery_days
FROM orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_purchase_timestamp IS NOT NULL;

    --Task 10 – Delivery Performance Analysis

    --Query 1: Average delivery time

    SELECT
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                order_delivered_customer_date -
                order_purchase_timestamp
            )) / 86400
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_purchase_timestamp IS NOT NULL;

    --Query 2: On-time vs late deliveries

    SELECT
    COUNT(*) AS total_delivered_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
        <= order_estimated_delivery_date
    ) AS on_time_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
        > order_estimated_delivery_date
    ) AS late_orders

FROM orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL;

    --Query 3: On-time delivery percentage

    SELECT
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date
            <= order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS on_time_delivery_percentage

FROM orders
WHERE
    order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL;

    --Task 11 – Payment Analysis

    --Query 11.1 – Payment method distribution

    SELECT
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

--Query 11.2 – Average payment value by payment method

SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY average_payment_value DESC;

--Query 11.3 – Installment analysis

SELECT
    payment_installments,
    COUNT(*) AS total_payment_records,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments
GROUP BY payment_installments
ORDER BY payment_installments;

--Task 12 – Seller Performance Analysis

--Query 12.1 – Top 10 sellers by revenue

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;

--Query 12.2 – Seller-wise average order value

SELECT
    s.seller_id,
    s.seller_city,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    s.seller_id,
    s.seller_city
ORDER BY average_order_value DESC
LIMIT 10;

--Query 12.3 – Seller performance by state

SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS total_sellers,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY total_revenue DESC;

