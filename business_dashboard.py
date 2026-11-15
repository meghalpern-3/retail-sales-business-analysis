
import csv
from pathlib import Path
import matplotlib.pyplot as plt

months = []
orders = []
avg_order_value = []

with open("outputs/monthly_average_order_value.csv", newline="") as file:
    data = csv.DictReader(file)

    for row in data:
        months.append(row["month"][5:])
        orders.append(int(row["total_orders"]))
        avg_order_value.append(float(row["average_order_value"]))

fig, charts = plt.subplots(2, 1, figsize=(9, 7))

charts[0].bar(months, orders, color="steelblue")
charts[0].set_title("Orders by Month")
charts[0].set_ylabel("Orders")

charts[1].plot(months, avg_order_value, marker="o", color="seagreen")
charts[1].set_title("Average Order Value by Month")
charts[1].set_ylabel("Dollars per Order")
charts[1].set_xlabel("Month")

plt.tight_layout()
Path("outputs").mkdir(exist_ok=True)
plt.savefig("outputs/business_dashboard.png", dpi=200)
plt.show()
