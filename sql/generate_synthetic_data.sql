USE bigbasket_analysis;

CREATE OR REPLACE VIEW vw_orders_full AS
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    c.city,
    c.customer_segment,
    o.product,
    o.category,
    o.sub_category,
    o.brand,
    o.quantity,
    o.sale_price,
    o.revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

CREATE OR REPLACE VIEW vw_monthly_summary AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    category,
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_units,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM orders
GROUP BY month, category;

CREATE OR REPLACE VIEW vw_customer_rfm AS
WITH rfm_base AS (
    SELECT
        o.customer_id,
        c.city,
        c.customer_segment,
        DATEDIFF('2023-12-31', MAX(o.order_date)) AS recency_days,
        COUNT(*) AS frequency,
        ROUND(SUM(o.revenue), 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.city, c.customer_segment
)
SELECT
    *,
    NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm_base;

SELECT * FROM vw_orders_full LIMIT 5;
SELECT * FROM vw_monthly_summary LIMIT 5;
SELECT * FROM vw_customer_rfm LIMIT 5;
