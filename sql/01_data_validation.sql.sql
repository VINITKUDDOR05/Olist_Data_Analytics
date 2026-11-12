--Validate all 9 tables

SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM customers

UNION ALL

SELECT 'orders', COUNT(*) FROM orders

UNION ALL

SELECT 'order_items', COUNT(*) FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*) FROM order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*) FROM order_reviews

UNION ALL

SELECT 'products', COUNT(*) FROM products

UNION ALL

SELECT 'sellers', COUNT(*) FROM sellers

UNION ALL

SELECT 'geolocation', COUNT(*) FROM geolocation

UNION ALL

SELECT 'category_translation', COUNT(*) FROM category_translation

ORDER BY table_name;

-- Checking missing values

SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NULL
    ) AS missing_purchase_date,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivery_date,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id

FROM orders;

--Check duplicate records
--Customers table:

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

--Orders table:

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
