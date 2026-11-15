
import csv
import sqlite3
from pathlib import Path

folder = Path(__file__).resolve().parent
data_folder = folder / "data"
output_folder = folder / "outputs"
output_folder.mkdir(exist_ok=True)

db = sqlite3.connect(":memory:")

db.executescript("""
CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    unit_price REAL,
    unit_cost REAL
);

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    order_date TEXT,
    product_id TEXT,
    quantity INTEGER,
    region TEXT,
    discount_pct REAL
);
""")

# Load the two CSV files into SQLite
for table, columns in [
    ("products", ["product_id", "product_name", "category", "unit_price", "unit_cost"]),
    ("orders", ["order_id", "order_date", "product_id", "quantity", "region", "discount_pct"])
]:
    with open(data_folder / f"{table}.csv", newline="") as file:
        data = csv.DictReader(file)
        rows = [tuple(row[column] for column in columns) for row in data]

    placeholders = ",".join(["?"] * len(columns))
    db.executemany(f"INSERT INTO {table} VALUES ({placeholders})", rows)

db.commit()

with open(folder / "sql" / "analysis.sql") as file:
    queries = file.read()

# Run each query and save its results
for section in queries.split("-- QUERY:")[1:]:
    name, sql = section.split("\n", 1)
    name = name.strip()

    result = db.execute(sql.strip().rstrip(";"))
    column_names = [column[0] for column in result.description]
    rows = result.fetchall()

    filename = name.lower().replace(" ", "_") + ".csv"

    with open(output_folder / filename, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(column_names)
        writer.writerows(rows)

    print(f"\n{name}")
    print(" | ".join(column_names))

    for row in rows[:12]:
        print(" | ".join(str(value) for value in row))

    print(f"Saved: outputs/{filename}")

db.close()
