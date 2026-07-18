USE bigbasket_analysis;

-- 1. Month-over-month revenue growth
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(revenue) AS total_revenue
    FROM orders GROUP BY month
)
SELECT month, total_revenue,
       LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY month))
             / LAG(total_revenue) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly ORDER BY month;

-- 2. Top 10 best-selling products
SELECT product, category, brand,
       SUM(quantity) AS units_sold,
       ROUND(SUM(revenue), 2) AS total_revenue
FROM orders
GROUP BY product, category, brand
ORDER BY total_revenue DESC LIMIT 10;

-- 3. Top brands by revenue
SELECT brand, COUNT(DISTINCT product) AS num_products_sold,
       ROUND(SUM(revenue), 2) AS total_revenue
FROM orders
WHERE brand IS NOT NULL AND brand != ''
GROUP BY brand ORDER BY total_revenue DESC LIMIT 10;

-- 4. City-wise revenue
SELECT c.city,
       COUNT(DISTINCT o.customer_id) AS num_customers,
       COUNT(o.order_id) AS total_orders,
       ROUND(SUM(o.revenue), 2) AS total_revenue,
       ROUND(SUM(o.revenue) / COUNT(DISTINCT o.customer_id), 2) AS revenue_per_customer
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city ORDER BY total_revenue DESC;

-- 5. RFM customer segmentation
WITH rfm_base AS (
    SELECT customer_id,
           DATEDIFF('2023-12-31', MAX(order_date)) AS recency_days,
           COUNT(*) AS frequency,
           ROUND(SUM(revenue), 2) AS monetary
    FROM orders GROUP BY customer_id
),
rfm_scored AS (
    SELECT customer_id, recency_days, frequency, monetary,
           NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
           NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
           NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT customer_id, recency_days, frequency, monetary,
       (r_score + f_score + m_score) AS rfm_total,
       CASE
           WHEN (r_score + f_score + m_score) >= 10 THEN 'Champions'
           WHEN (r_score + f_score + m_score) >= 7  THEN 'Loyal Customers'
           WHEN (r_score + f_score + m_score) >= 5  THEN 'At Risk'
           ELSE 'Lost / Low Value'
       END AS customer_segment
FROM rfm_scored
ORDER BY rfm_total DESC;
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
