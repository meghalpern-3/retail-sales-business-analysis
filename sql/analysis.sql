
-- QUERY: Overall performance
SELECT
    COUNT(*) AS orders,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 2) AS revenue,
    ROUND(SUM(o.quantity * (p.unit_price * (1 - o.discount_pct) - p.unit_cost)), 2) AS gross_profit
FROM orders o
JOIN products p ON o.product_id = p.product_id;


-- QUERY: Monthly revenue
SELECT
    SUBSTR(o.order_date, 1, 7) AS month,
    COUNT(*) AS orders,
    ROUND(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 2) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY month
ORDER BY month;


-- QUERY: Category performance
SELECT
    p.category,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 2) AS revenue,
    ROUND(SUM(o.quantity * (p.unit_price * (1 - o.discount_pct) - p.unit_cost)), 2) AS gross_profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;


-- QUERY: Regional performance
SELECT
    o.region,
    COUNT(*) AS orders,
    ROUND(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 2) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY o.region
ORDER BY revenue DESC;


-- QUERY: Top products
SELECT
    p.product_name,
    p.category,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 2) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id
ORDER BY revenue DESC
LIMIT 5;


-- QUERY: Month-over-month revenue growth
WITH monthly_sales AS (
    SELECT
        SUBSTR(o.order_date, 1, 7) AS month,
        SUM(o.quantity * p.unit_price * (1 - o.discount_pct)) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY month
),
revenue_comparison AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0), 2
    ) AS revenue_growth_pct
FROM revenue_comparison
ORDER BY month;


-- QUERY: Monthly average order value
SELECT
    SUBSTR(o.order_date, 1, 7) AS month,
    COUNT(*) AS total_orders,
    ROUND(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 2) AS revenue,
    ROUND(
        SUM(o.quantity * p.unit_price * (1 - o.discount_pct)) / COUNT(*), 2
    ) AS average_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY month
ORDER BY month;


-- QUERY: Category profit margins
SELECT
    p.category,
    ROUND(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 2) AS revenue,
    ROUND(SUM(o.quantity * (p.unit_price * (1 - o.discount_pct) - p.unit_cost)), 2) AS gross_profit,
    ROUND(
        100.0 * SUM(o.quantity * (p.unit_price * (1 - o.discount_pct) - p.unit_cost))
        / NULLIF(SUM(o.quantity * p.unit_price * (1 - o.discount_pct)), 0),
        2
    ) AS gross_margin_pct
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY gross_margin_pct DESC;
