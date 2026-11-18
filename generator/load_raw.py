import duckdb
from pathlib import Path

con = duckdb.connect("enhance.duckdb")
con.execute("create schema if not exists raw")

for csv in sorted(Path("data/raw").glob("*.csv")):
    t = csv.stem
    con.execute(f"""
        create or replace table raw.{t} as
        select *, current_timestamp as _loaded_at
        from read_csv_auto('{csv.as_posix()}')
    """)
    print(t, con.execute(f"select count(*) from raw.{t}").fetchone()[0])
con.close()