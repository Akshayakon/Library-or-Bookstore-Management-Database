"""Build library.db from schema.sql + seed.sql, then run every query in queries.sql."""
import re
import sqlite3
from pathlib import Path

here = Path(__file__).parent
db_path = here / "library.db"
db_path.unlink(missing_ok=True)

con = sqlite3.connect(db_path)
con.execute("PRAGMA foreign_keys = ON")
con.executescript((here / "schema.sql").read_text(encoding="utf-8"))
con.executescript((here / "seed.sql").read_text(encoding="utf-8"))
con.commit()
print(f"Built {db_path.name}\n")

text = (here / "queries.sql").read_text(encoding="utf-8")
# Split into (title, sql) blocks on the "-- Qn." comment headers.
for block in re.split(r"(?m)^(?=-- Q\d+\.)", text):
    m = re.match(r"-- (Q\d+\..*)", block)
    if not m:
        continue
    cur = con.execute(block)
    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    print("=" * 70, f"\n{m.group(1)}\n" + "=" * 70)
    widths = [max(len(str(x)) for x in [c] + [r[i] for r in rows]) for i, c in enumerate(cols)]
    print("  ".join(c.ljust(w) for c, w in zip(cols, widths)))
    print("  ".join("-" * w for w in widths))
    for r in rows:
        print("  ".join(str(x).ljust(w) for x, w in zip(r, widths)))
    if not rows:
        print("(no rows)")
    print()
