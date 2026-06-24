-- ============================================================
-- Restaurant Database Management System
-- Author: Bharath Gurujala
-- ============================================================

CREATE DATABASE IF NOT EXISTS restaurant_db;
USE restaurant_db;

-- ─── Tables ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS staff (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    role        VARCHAR(50) NOT NULL,   -- Chef, Waiter, Manager, Cashier
    phone       VARCHAR(15),
    shift       VARCHAR(20),           -- Morning, Afternoon, Evening
    hired_date  DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS tables_list (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT UNIQUE NOT NULL,
    capacity        INT NOT NULL,
    status          ENUM('Available', 'Occupied', 'Reserved') DEFAULT 'Available'
);

CREATE TABLE IF NOT EXISTS categories (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(50) NOT NULL UNIQUE   -- Starters, Main Course, Beverages, Desserts
);

CREATE TABLE IF NOT EXISTS menu (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    category_id     INT,
    price           DECIMAL(8,2) NOT NULL,
    is_available    BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS inventory (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    item_name       VARCHAR(100) NOT NULL,
    quantity        DECIMAL(10,2) NOT NULL DEFAULT 0,
    unit            VARCHAR(20) NOT NULL,   -- kg, litre, pieces
    reorder_level   DECIMAL(10,2) NOT NULL,
    last_updated    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_id        INT,
    staff_id        INT,
    order_time      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('Pending', 'Preparing', 'Served', 'Cancelled') DEFAULT 'Pending',
    total_amount    DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (table_id) REFERENCES tables_list(id) ON DELETE SET NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS order_items (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT NOT NULL,
    menu_id     INT NOT NULL,
    quantity    INT NOT NULL DEFAULT 1,
    unit_price  DECIMAL(8,2) NOT NULL,
    subtotal    DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES menu(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT UNIQUE NOT NULL,
    amount_paid     DECIMAL(10,2) NOT NULL,
    method          ENUM('Cash', 'UPI', 'Card', 'Online') NOT NULL,
    payment_time    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- ─── Sample Data ─────────────────────────────────────────────

INSERT INTO categories (name) VALUES ('Starters'), ('Main Course'), ('Beverages'), ('Desserts');

INSERT INTO staff (name, role, phone, shift, hired_date) VALUES
('Ravi Kumar',   'Manager', '9876543210', 'Morning',   '2023-01-15'),
('Priya Sharma', 'Chef',    '9876543211', 'Afternoon', '2023-03-10'),
('Arjun Singh',  'Waiter',  '9876543212', 'Evening',   '2023-06-01');

INSERT INTO tables_list (table_number, capacity, status) VALUES
(1, 2, 'Available'), (2, 4, 'Available'), (3, 6, 'Available'),
(4, 4, 'Available'), (5, 8, 'Available');

INSERT INTO menu (name, category_id, price, is_available) VALUES
('Veg Spring Rolls',    1, 120.00, TRUE),
('Chicken Tikka',       1, 220.00, TRUE),
('Paneer Butter Masala',2, 280.00, TRUE),
('Chicken Biryani',     2, 320.00, TRUE),
('Dal Tadka',           2, 180.00, TRUE),
('Mango Lassi',         3,  80.00, TRUE),
('Fresh Lime Soda',     3,  60.00, TRUE),
('Gulab Jamun',         4, 100.00, TRUE);

INSERT INTO inventory (item_name, quantity, unit, reorder_level) VALUES
('Paneer',         5.0,   'kg',     2.0),
('Chicken',       10.0,   'kg',     3.0),
('Rice',          20.0,   'kg',     5.0),
('Cooking Oil',    8.0,   'litre',  2.0),
('Tomatoes',       6.0,   'kg',     2.0),
('Onions',        10.0,   'kg',     3.0),
('Milk',           5.0,   'litre',  2.0);
