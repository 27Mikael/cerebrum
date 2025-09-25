import sqlite3

conn = sqlite3.connect("../storage/study/")
c = conn.cursor()

c.execute("""
CREATE TABLE IF NOT EXISTS quizzes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question TEXT,
    answer TEXT,
    correct BOOLEAN,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
)
""")
conn.commit()
print("✅ Rose's study tracker DB is ready.")
