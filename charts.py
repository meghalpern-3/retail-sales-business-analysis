from pathlib import Path
import csv
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'outputs'
if not (OUT / 'monthly_revenue.csv').exists():
    raise SystemExit('Run python analyze.py first.')

for filename, xcol, title, output in [
    ('monthly_revenue.csv', 'month', 'Monthly Revenue', 'monthly_revenue.png'),
    ('category_performance.csv', 'category', 'Revenue by Category', 'category_revenue.png'),
]:
    with (OUT / filename).open(newline='') as file:
        rows = list(csv.DictReader(file))
    fig, ax = plt.subplots(figsize=(9, 4.5))
    ax.bar([r[xcol] for r in rows], [float(r['revenue']) for r in rows])
    ax.set_title(title)
    ax.set_ylabel('Revenue ($)')
    ax.tick_params(axis='x', rotation=45)
    fig.tight_layout()
    fig.savefig(OUT / output, dpi=160)
    plt.close(fig)
    print(f'Saved outputs/{output}')
