USE bigbasket_analysis;

CREATE OR REPLACE VIEW vw_customer_rfm AS
WITH rfm_base AS (
    SELECT
        o.customer_id,
        c.city,
        c.customer_segment AS account_type,
        DATEDIFF('2023-12-31', MAX(o.order_date)) AS recency_days,
        COUNT(*) AS frequency,
        ROUND(SUM(o.revenue), 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.city, c.customer_segment
),
rfm_scored AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT
    *,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 5  THEN 'At Risk'
        ELSE 'Lost / Low Value'
    END AS rfm_segment
FROM rfm_scored;

SELECT * FROM vw_customer_rfm LIMIT 5;
