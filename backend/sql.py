import sqlite3
from pathlib import Path

# ✅ Change this path if needed
DB_PATH = Path("../local_server/data/registry.db")

# ✅ Make sure the directory exists
DB_PATH.parent.mkdir(parents=True, exist_ok=True)

try:
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Create a tiny test table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS test_table (
        id INTEGER PRIMARY KEY,
        name TEXT
    );
    """)

    # Insert a dummy row
    cursor.execute("INSERT INTO test_table (name) VALUES (?);", ("hello",))
    conn.commit()

    # Read it back
    cursor.execute("SELECT * FROM test_table;")
    rows = cursor.fetchall()
    conn.close()

    print("✅ Success! Rows in table:", rows)
    print("✅ DB stored at:", DB_PATH.resolve())

except Exception as e:
    print("❌ Error:", e)
