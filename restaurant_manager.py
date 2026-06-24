import mysql.connector
from datetime import date

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'password',
    'database': 'restaurant_db'
}


def get_connection():
    return mysql.connector.connect(**DB_CONFIG)


# ─── Menu ─────────────────────────────────────────────────────

def get_menu():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT m.id, m.name, c.name AS category, m.price, m.is_available
        FROM menu m JOIN categories c ON m.category_id = c.id
        WHERE m.is_available = TRUE
        ORDER BY c.name, m.name
    """)
    items = cursor.fetchall()
    conn.close()
    return items

def add_menu_item(name, category_id, price):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO menu (name, category_id, price) VALUES (%s, %s, %s)", (name, category_id, price))
    conn.commit()
    conn.close()
    print(f"Menu item '{name}' added.")


# ─── Orders ───────────────────────────────────────────────────

def place_order(table_id, staff_id, items):
    """
    items: list of dicts with {menu_id, quantity, unit_price}
    """
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO orders (table_id, staff_id, status) VALUES (%s, %s, 'Pending')", (table_id, staff_id))
    order_id = cursor.lastrowid

    for item in items:
        cursor.execute(
            "INSERT INTO order_items (order_id, menu_id, quantity, unit_price) VALUES (%s, %s, %s, %s)",
            (order_id, item['menu_id'], item['quantity'], item['unit_price'])
        )

    cursor.execute("UPDATE orders SET total_amount = (SELECT SUM(subtotal) FROM order_items WHERE order_id = %s) WHERE id = %s", (order_id, order_id))
    cursor.execute("UPDATE tables_list SET status = 'Occupied' WHERE id = %s", (table_id,))
    conn.commit()
    conn.close()
    print(f"Order #{order_id} placed successfully.")
    return order_id

def update_order_status(order_id, status):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE orders SET status = %s WHERE id = %s", (status, order_id))
    conn.commit()
    conn.close()
    print(f"Order #{order_id} status updated to {status}.")

def get_order_details(order_id):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT o.id, t.table_number, s.name AS staff, o.status, o.total_amount, o.order_time,
               m.name AS item, oi.quantity, oi.unit_price, oi.subtotal
        FROM orders o
        JOIN tables_list t ON o.table_id = t.id
        JOIN staff s ON o.staff_id = s.id
        JOIN order_items oi ON oi.order_id = o.id
        JOIN menu m ON oi.menu_id = m.id
        WHERE o.id = %s
    """, (order_id,))
    rows = cursor.fetchall()
    conn.close()
    return rows


# ─── Payments ─────────────────────────────────────────────────

def process_payment(order_id, amount, method):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO payments (order_id, amount_paid, method) VALUES (%s, %s, %s)", (order_id, amount, method))
    cursor.execute("UPDATE orders SET status = 'Served' WHERE id = %s", (order_id,))
    cursor.execute("UPDATE tables_list SET status = 'Available' WHERE id = (SELECT table_id FROM orders WHERE id = %s)", (order_id,))
    conn.commit()
    conn.close()
    print(f"Payment of ₹{amount} via {method} recorded for Order #{order_id}.")


# ─── Reports ──────────────────────────────────────────────────

def daily_sales_report():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT DATE(payment_time) AS date, SUM(amount_paid) AS revenue, COUNT(*) AS orders
        FROM payments GROUP BY DATE(payment_time) ORDER BY date DESC LIMIT 7
    """)
    report = cursor.fetchall()
    conn.close()
    return report

def top_selling_items(limit=5):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT m.name, SUM(oi.quantity) AS total_sold, SUM(oi.subtotal) AS revenue
        FROM order_items oi JOIN menu m ON oi.menu_id = m.id
        GROUP BY m.id ORDER BY total_sold DESC LIMIT %s
    """, (limit,))
    items = cursor.fetchall()
    conn.close()
    return items

def low_stock_items():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT item_name, quantity, unit, reorder_level FROM inventory WHERE quantity <= reorder_level")
    items = cursor.fetchall()
    conn.close()
    return items


# ─── CLI Demo ─────────────────────────────────────────────────

if __name__ == '__main__':
    print("\n===== MENU =====")
    for item in get_menu():
        print(f"  [{item['id']}] {item['name']} ({item['category']}) - ₹{item['price']}")

    print("\n===== DAILY SALES =====")
    for row in daily_sales_report():
        print(f"  {row['date']}: ₹{row['revenue']} from {row['orders']} orders")

    print("\n===== TOP SELLING ITEMS =====")
    for item in top_selling_items():
        print(f"  {item['name']}: {item['total_sold']} sold, ₹{item['revenue']} revenue")

    print("\n===== LOW STOCK ALERT =====")
    low = low_stock_items()
    if low:
        for item in low:
            print(f"  ⚠ {item['item_name']}: {item['quantity']} {item['unit']} remaining (reorder at {item['reorder_level']})")
    else:
        print("  All items sufficiently stocked.")
