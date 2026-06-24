# 🍽️ Restaurant Database Management System

A relational database solution to streamline restaurant operations — order management, inventory tracking, menu management, staff, and operational reporting.

---

## 🚀 Features

- 📋 Menu management with categories and availability
- 🛒 Order placement and status tracking
- 💰 Payment processing (Cash, UPI, Card, Online)
- 📦 Inventory tracking with low-stock alerts
- 👨‍🍳 Staff management and performance reports
- 📊 Daily, weekly, monthly sales reports
- 🪑 Table occupancy management

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Database | MySQL |
| Query Language | SQL |
| Python Interface | mysql-connector-python |

---

## 📁 Project Structure

```
restaurant_db/
├── schema.sql              # Full database schema + sample data
├── queries.sql             # All useful queries (reports, analytics)
├── restaurant_manager.py   # Python interface for DB operations
├── requirements.txt
└── README.md
```

---

## 🗃️ Database Schema

```
categories      → id, name
menu            → id, name, category_id, price, is_available
staff           → id, name, role, phone, shift, hired_date
tables_list     → id, table_number, capacity, status
inventory       → id, item_name, quantity, unit, reorder_level
orders          → id, table_id, staff_id, status, total_amount, order_time
order_items     → id, order_id, menu_id, quantity, unit_price, subtotal
payments        → id, order_id, amount_paid, method, payment_time
```

---

## ⚙️ Setup & Installation

### 1. Clone the repository
```bash
git clone https://github.com/your-username/restaurant-db-management.git
cd restaurant-db-management
```

### 2. Set up the database
```bash
mysql -u root -p < schema.sql
```

### 3. Install Python dependencies
```bash
pip install -r requirements.txt
```

### 4. Update DB config in restaurant_manager.py
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'your_password',
    'database': 'restaurant_db'
}
```

### 5. Run the Python manager
```bash
python restaurant_manager.py
```

---

## 👨‍💻 Developer

**Bharath Gurujala** — Database Developer  

🔗 [LinkedIn](https://www.linkedin.com/in/bharath-gurujala-40093b229)
