import numpy as np, pandas as pd
from pathlib import Path

rng = np.random.default_rng(42)
out = Path("data/raw"); out.mkdir(parents=True, exist_ok=True)

clubs = pd.DataFrame({
    "club_id": range(1, 7),
    "club_name": ["Marina", "JLT", "Downtown", "Business Bay", "Al Barsha", "Palm"],
    "pt_rooms": [3, 2, 4, 3, 2, 3],
    "opened_date": pd.to_datetime(["2022-01-10", "2022-06-01", "2023-02-15",
                                   "2023-09-01", "2024-03-01", "2024-10-01"]),
})

trainers = pd.DataFrame({
    "trainer_id": range(1, 41),
    "club_id": rng.integers(1, 7, 40),
    "commission_rate": rng.choice([0.35, 0.40, 0.45, 0.50], 40),
    "weekly_available_hours": rng.integers(25, 41, 40),
    "hire_date": pd.to_datetime("2022-01-01") + pd.to_timedelta(rng.integers(0, 900, 40), unit="D"),
})

package_types = pd.DataFrame({
    "package_type_id": range(1, 6),
    "package_name": ["Trial 3", "Starter 5", "Standard 10", "Pro 20", "Elite 30"],
    "sessions_included": [3, 5, 10, 20, 30],
    "list_price_aed": [450, 700, 1300, 2400, 3300],
    "validity_days": [30, 60, 90, 180, 270],
})

for name, df in {"clubs": clubs, "trainers": trainers, "package_types": package_types}.items():
    df.to_csv(out / f"{name}.csv", index=False)
    print(name, df.shape)