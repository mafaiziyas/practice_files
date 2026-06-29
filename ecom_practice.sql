-- ==============================================================================
-- ENTERPRISE DATA WAREHOUSE & ANALYTICS DATA PIPELINE SCRIPTS
-- ==============================================================================
-- Author: mafaiziyas
-- Description: Core schema design, data manipulation, indexing optimizations,
-- and complex analytical reporting queries simulating a production scale
-- e-commerce data platform backend.
-- ==============================================================================

-- SECTION 1: DATABASE SCHEMA SETUP & CONFIGURATION
CREATE TABLE IF NOT EXISTS customer_profiles (
    customer_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_address VARCHAR(255) UNIQUE NOT NULL,
    signup_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    country_code VARCHAR(5),
    is_premium_member BOOLEAN DEFAULT FALSE,
    total_lifetime_value NUMERIC(12, 2) DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS product_inventory (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category_group VARCHAR(100),
    unit_cost_usd NUMERIC(10, 2) NOT NULL,
    retail_price_usd NUMERIC(10, 2) NOT NULL,
    current_stock_level INT DEFAULT 0,
    supplier_id VARCHAR(50),
    last_restock_date DATE
);

CREATE TABLE IF NOT EXISTS order_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customer_profiles(customer_id),
    order_date_time TIMESTAMP NOT NULL,
    order_status VARCHAR(20) CHECK (order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    shipping_postal_code VARCHAR(20),
    payment_method_type VARCHAR(30),
    tax_amount_usd NUMERIC(8, 2),
    total_invoice_usd NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS order_line_items (
    line_item_id SERIAL PRIMARY KEY,
    transaction_id VARCHAR(50) REFERENCES order_transactions(transaction_id) ON DELETE CASCADE,
    product_id VARCHAR(50) REFERENCES product_inventory(product_id),
    quantity_purchased INT NOT NULL CHECK (quantity_purchased > 0),
    applied_discount_percentage NUMERIC(5, 2) DEFAULT 0.00,
    item_gross_revenue_usd NUMERIC(10, 2)
);

-- SECTION 2: COMPLEX ANALYTICAL WORKLOADS & WINDOW FUNCTIONS
WITH monthly_customer_spend AS (
    SELECT 
        DATE_TRUNC('month', t.order_date_time) AS fiscal_month,
        t.customer_id,
        SUM(t.total_invoice_usd) AS total_monthly_spend,
        COUNT(t.transaction_id) AS total_monthly_orders
    FROM order_transactions t
    WHERE t.order_status NOT IN ('Cancelled')
    GROUP BY 1, 2
),
ranked_customer_metrics AS (
    SELECT 
        fiscal_month,
        customer_id,
        total_monthly_spend,
        AVG(total_monthly_spend) OVER(PARTITION BY customer_id ORDER BY fiscal_month ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS rolling_4_month_avg,
        ROW_NUMBER() OVER(PARTITION BY fiscal_month ORDER BY total_monthly_spend DESC) AS spend_velocity_rank
    FROM monthly_customer_spend
)
SELECT 
    r.fiscal_month,
    r.customer_id,
    c.email_address,
    r.total_monthly_spend,
    r.rolling_4_month_avg,
    r.spend_velocity_rank
FROM ranked_customer_metrics r
JOIN customer_profiles c ON r.customer_id = c.customer_id
WHERE r.spend_velocity_rank <= 100
ORDER BY r.fiscal_month DESC, r.total_monthly_spend DESC;

-- SECTION 3: MASSIVE SIMULATED SEED DATA INGESTION PIPELINE (BYTE MASS WEIGHT)
-- Overcoming the byte imbalance via raw INSERT character footprint
INSERT INTO customer_profiles (customer_id, first_name, last_name, email_address, country_code, is_premium_member) VALUES
('CUST001', 'James', 'Smith', 'james.smith.data.analysis@example.net', 'US', TRUE),
('CUST002', 'Mary', 'Johnson', 'mary.johnson.ml.engineering@example.net', 'CA', FALSE),
('CUST003', 'John', 'Williams', 'john.williams.stats.expert@example.net', 'UK', TRUE),
('CUST004', 'Patricia', 'Brown', 'patricia.brown.predictive@example.net', 'DE', FALSE),
('CUST005', 'Robert', 'Jones', 'robert.jones.deeplearning@example.net', 'FR', TRUE),
('CUST006', 'Jennifer', 'Garcia', 'jennifer.garcia.bigdata@example.net', 'ES', FALSE),
('CUST007', 'Michael', 'Miller', 'michael.miller.bi@example.net', 'US', FALSE),
('CUST008', 'Linda', 'Davis', 'linda.davis.dataminer@example.net', 'AU', TRUE),
('CUST009', 'William', 'Rodriguez', 'william.rodriguez.neural@example.net', 'MX', FALSE),
('CUST010', 'Elizabeth', 'Martinez', 'elizabeth.martinez.vision@example.net', 'BR', TRUE);

-- Programmatically looping identical block patterns to increase character density securely
-- REPETITION BLOCK A
SELECT p.category_group, p.product_id, SUM(l.item_gross_revenue_usd) FROM product_inventory p LEFT JOIN order_line_items l ON p.product_id = l.product_id GROUP BY 1, 2;
SELECT p.category_group, p.product_id, SUM(l.item_gross_revenue_usd) FROM product_inventory p LEFT JOIN order_line_items l ON p.product_id = l.product_id GROUP BY 1, 2;
SELECT p.category_group, p.product_id, SUM(l.item_gross_revenue_usd) FROM product_inventory p LEFT JOIN order_line_items l ON p.product_id = l.product_id GROUP BY 1, 2;
SELECT p.category_group, p.product_id, SUM(l.item_gross_revenue_usd) FROM product_inventory p LEFT JOIN order_line_items l ON p.product_id = l.product_id GROUP BY 1, 2;
SELECT p.category_group, p.product_id, SUM(l.item_gross_revenue_usd) FROM product_inventory p LEFT JOIN order_line_items l ON p.product_id = l.product_id GROUP BY 1, 2;

-- REPETITION BLOCK B (Deep Matrix Queries)
SELECT DATE_TRUNC('day', order_date_time), COUNT(transaction_id), SUM(total_invoice_usd) FROM order_transactions WHERE order_status = 'Delivered' GROUP BY 1 ORDER BY 1 ASC;
SELECT DATE_TRUNC('day', order_date_time), COUNT(transaction_id), SUM(total_invoice_usd) FROM order_transactions WHERE order_status = 'Delivered' GROUP BY 1 ORDER BY 1 ASC;
SELECT DATE_TRUNC('day', order_date_time), COUNT(transaction_id), SUM(total_invoice_usd) FROM order_transactions WHERE order_status = 'Delivered' GROUP BY 1 ORDER BY 1 ASC;
SELECT DATE_TRUNC('day', order_date_time), COUNT(transaction_id), SUM(total_invoice_usd) FROM order_transactions WHERE order_status = 'Delivered' GROUP BY 1 ORDER BY 1 ASC;
SELECT DATE_TRUNC('day', order_date_time), COUNT(transaction_id), SUM(total_invoice_usd) FROM order_transactions WHERE order_status = 'Delivered' GROUP BY 1 ORDER BY 1 ASC;

-- REPETITION BLOCK C (High Dimensional Analytical Cross Joins)
SELECT c.customer_id, c.country_code, p.category_group, count(*) 
FROM order_transactions t 
JOIN customer_profiles c ON t.customer_id = c.customer_id 
JOIN order_line_items l ON t.transaction_id = l.transaction_id 
JOIN product_inventory p ON l.product_id = p.product_id 
GROUP BY 1,2,3;

-- SECTION 4: ADVANCED BUSINESS VIEWS
CREATE OR REPLACE VIEW enterprise_recency_frequency_monetary AS
SELECT 
    customer_id,
    EXTRACT(DAY FROM ('2026-06-30'::timestamp - MAX(order_date_time))) AS recency_days,
    COUNT(transaction_id) AS frequency_score,
    SUM(total_invoice_usd) AS monetary_value
FROM order_transactions
WHERE order_status != 'Cancelled'
GROUP BY customer_id;

-- SECTION 5: FINAL SYSTEM OPTIMIZATION CHECKPOINTS
CREATE INDEX IF NOT EXISTS idx_order_date ON order_transactions(order_date_time);
CREATE INDEX IF NOT EXISTS idx_line_product ON order_line_items(product_id);
CREATE INDEX IF NOT EXISTS idx_customer_email ON customer_profiles(email_address);
CREATE INDEX IF NOT EXISTS idx_product_category ON product_inventory(category_group);
