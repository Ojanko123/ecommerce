--Creating the table first.
CREATE TABLE retail (
    invoice        TEXT,
    stock_code     TEXT,
    description    TEXT,
    quantity       INT,
    invoice_date   TIMESTAMP,
    price          NUMERIC,
    customer_id    TEXT,
    country        TEXT
);
--after importing the data I want to get a quick idea about how does it look.
SELECT COUNT(*) FROM retail;
SELECT * FROM retail LIMIT 5;
SELECT COUNT(*) FROM retail WHERE customer_id IS NULL;
SELECT COUNT(*) FROM retail WHERE quantity <= 0;
/* I am Observing a big number of null customer's id , but there is no problem at this point.
Null values dont bother us when we analyze revenue,products,countries.
If needed, I will exclude them on a seperate query when customr analysis is being the subject of analysis 
*/


--What needs to be excluded is price values <=0.
CREATE VIEW retail_clean AS
SELECT *
FROM retail
WHERE quantity > 0
AND price > 0;
SELECT COUNT(*) FROM retail_clean;


--Calculating revenue per month (Revenue peaks massively in Q4)
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    ROUND(SUM(quantity * price)::NUMERIC, 2) AS total_revenue
FROM retail_clean
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month;

--Calculating the total revenue (nearly £21 million)
SELECT ROUND(SUM(quantity * price)::NUMERIC, 2) AS total_revenue
FROM retail_clean;

--Top customers (Excluding null values)
SELECT 
    SPLIT_PART(customer_id, '.', 1) AS customer_id,
    ROUND(SUM(quantity * price)::NUMERIC, 2) AS total_spent,
    COUNT(DISTINCT invoice) AS total_orders
FROM retail_clean
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

--Top products
SELECT 
    stock_code,
    description,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(quantity * price)::NUMERIC, 2) AS total_revenue
FROM retail_clean
GROUP BY stock_code, description
ORDER BY total_revenue DESC
LIMIT 10;

--manual is not a real product nor is dotcompostage and postage therefore I have to clean it.

SELECT 
    stock_code,
    description,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(quantity * price)::NUMERIC, 2) AS total_revenue
FROM retail_clean
WHERE stock_code NOT IN ('M', 'POST', 'DOT')
AND description NOT ILIKE '%postage%'
GROUP BY stock_code, description
ORDER BY total_revenue DESC
LIMIT 10;


--Calculating the average order value
SELECT
    ROUND(AVG(order_total)::NUMERIC, 2) AS avg_order_value
FROM (
    SELECT 
        invoice,
        SUM(quantity * price) AS order_total
    FROM retail_clean
    WHERE customer_id IS NOT NULL
    GROUP BY invoice
) AS order_totals;



--Top countries by revenue (excluding UK, Sweden is in the top 10)
SELECT
    country,
    ROUND(SUM(quantity * price)::NUMERIC, 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS total_customers
FROM retail_clean
WHERE country != 'United Kingdom'
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 10;


--Average customer lifetime value(without the nulls once again)
SELECT
    SPLIT_PART(customer_id, '.', 1) AS customer_id,
    ROUND(SUM(quantity * price)::NUMERIC, 2) AS lifetime_value,
    COUNT(DISTINCT invoice) AS total_orders,
    MIN(invoice_date)::DATE AS first_purchase,
    MAX(invoice_date)::DATE AS last_purchase
FROM retail_clean
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY lifetime_value DESC
LIMIT 10;


--Percentage of customers who ordered more than once
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) 
        / COUNT(*)::NUMERIC, 2) AS repeat_rate_pct
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice) AS total_orders
    FROM retail_clean
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_orders;

-- Month over month revenue growth using LAG window function
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', invoice_date) AS month,
        ROUND(SUM(quantity * price)::NUMERIC, 2) AS total_revenue
    FROM retail_clean
    GROUP BY DATE_TRUNC('month', invoice_date)
)
SELECT
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY month))
        / LAG(total_revenue) OVER (ORDER BY month), 2
    ) AS growth_pct
FROM monthly_revenue
ORDER BY month;

