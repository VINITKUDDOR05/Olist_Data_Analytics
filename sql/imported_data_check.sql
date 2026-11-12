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

