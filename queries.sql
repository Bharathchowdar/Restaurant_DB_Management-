-- ============================================================
-- Restaurant Database Management System — Useful Queries
-- Author: Bharath Gurujala
-- ============================================================

USE restaurant_db;

-- ─── Order Management ────────────────────────────────────────

-- Place a new order
INSERT INTO orders (table_id, staff_id, status) VALUES (2, 3, 'Pending');

-- Add items to an order
INSERT INTO order_items (order_id, menu_id, quantity, unit_price) VALUES
(1, 3, 2, 280.00),
(1, 6, 2, 80.00);

-- Update order total
UPDATE orders o
SET total_amount = (
    SELECT SUM(subtotal) FROM order_items WHERE order_id = o.id
)
WHERE o.id = 1;

-- Update order status
UPDATE orders SET status = 'Serving' WHERE id = 1;

-- Full order details with items
SELECT
    o.id AS order_id,
    t.table_number,
    s.name AS staff_name,
    m.name AS item,
    oi.quantity,
    oi.unit_price,
    oi.subtotal,
    o.status,
    o.order_time
FROM orders o
JOIN tables_list t ON o.table_id = t.id
JOIN staff s ON o.staff_id = s.id
JOIN order_items oi ON oi.order_id = o.id
JOIN menu m ON oi.menu_id = m.id
WHERE o.id = 1;

-- ─── Sales Reports ───────────────────────────────────────────

-- Today's total sales
SELECT SUM(amount_paid) AS total_sales_today
FROM payments
WHERE DATE(payment_time) = CURDATE();

-- Daily sales report
SELECT DATE(payment_time) AS date, SUM(amount_paid) AS daily_revenue, COUNT(*) AS total_orders
FROM payments
GROUP BY DATE(payment_time)
ORDER BY date DESC;

-- Weekly revenue
SELECT WEEK(payment_time) AS week, SUM(amount_paid) AS weekly_revenue
FROM payments
GROUP BY WEEK(payment_time)
ORDER BY week DESC;

-- Monthly revenue
SELECT MONTH(payment_time) AS month, SUM(amount_paid) AS monthly_revenue
FROM payments
GROUP BY MONTH(payment_time)
ORDER BY month DESC;

-- ─── Top-Selling Items ────────────────────────────────────────

-- Top 5 best-selling menu items
SELECT
    m.name AS item,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.subtotal) AS total_revenue
FROM order_items oi
JOIN menu m ON oi.menu_id = m.id
GROUP BY m.id, m.name
ORDER BY total_sold DESC
LIMIT 5;

-- Revenue by category
SELECT
    c.name AS category,
    SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN menu m ON oi.menu_id = m.id
JOIN categories c ON m.category_id = c.id
GROUP BY c.name
ORDER BY revenue DESC;

-- ─── Inventory Reports ───────────────────────────────────────

-- Low stock items (below reorder level)
SELECT item_name, quantity, unit, reorder_level
FROM inventory
WHERE quantity <= reorder_level
ORDER BY quantity ASC;

-- Full inventory status
SELECT
    item_name,
    quantity,
    unit,
    reorder_level,
    CASE
        WHEN quantity <= reorder_level THEN 'LOW STOCK'
        WHEN quantity <= reorder_level * 1.5 THEN 'MODERATE'
        ELSE 'SUFFICIENT'
    END AS stock_status
FROM inventory
ORDER BY stock_status;

-- ─── Staff Performance ───────────────────────────────────────

-- Orders handled per staff member
SELECT
    s.name AS staff_name,
    s.role,
    COUNT(o.id) AS orders_handled,
    SUM(o.total_amount) AS total_sales
FROM staff s
LEFT JOIN orders o ON o.staff_id = s.id
GROUP BY s.id, s.name, s.role
ORDER BY orders_handled DESC;

-- ─── Table Utilization ───────────────────────────────────────

-- Table occupancy report
SELECT
    t.table_number,
    t.capacity,
    t.status,
    COUNT(o.id) AS total_orders
FROM tables_list t
LEFT JOIN orders o ON o.table_id = t.id
GROUP BY t.id, t.table_number, t.capacity, t.status
ORDER BY total_orders DESC;

-- ─── Payment Methods ─────────────────────────────────────────

-- Revenue by payment method
SELECT
    method,
    COUNT(*) AS transactions,
    SUM(amount_paid) AS total_revenue
FROM payments
GROUP BY method
ORDER BY total_revenue DESC;
