import numpy as np, pandas as pd
from pathlib import Path

rng = np.random.default_rng(7)
raw = Path("data/raw")
TODAY = pd.Timestamp("2026-11-19")

clubs = pd.read_csv(raw / "clubs.csv", parse_dates=["opened_date"])
trainers = pd.read_csv(raw / "trainers.csv", parse_dates=["hire_date"])
pkgs = pd.read_csv(raw / "package_types.csv")

opened = clubs.set_index("club_id")["opened_date"]
club_w = (clubs["pt_rooms"] / clubs["pt_rooms"].sum()).to_numpy()
trainers_by_club = {c: g["trainer_id"].tolist() for c, g in trainers.groupby("club_id")}
all_trainers = trainers["trainer_id"].tolist()

# --- clients ---
N_CLIENTS = 2000
clients = []
for cid in range(1, N_CLIENTS + 1):
    club = int(rng.choice(clubs["club_id"], p=club_w))
    start = max(opened[club], pd.Timestamp("2023-01-01"))
    span = (pd.Timestamp("2026-10-31") - start).days
    signup = start + pd.Timedelta(days=int(rng.integers(0, span)))
    channel = str(rng.choice(["walk_in", "referral", "instagram", "corporate"],
                             p=[0.35, 0.25, 0.30, 0.10]))
    clients.append((cid, club, signup, channel))
clients = pd.DataFrame(clients, columns=["client_id", "home_club_id", "signup_date", "acquisition_channel"])

# --- purchases, sessions, payments ---
PKG_P = [0.20, 0.30, 0.30, 0.15, 0.05]
purchases, sessions, payments = [], [], []
pid = sid = pay_id = 0

for c in clients.itertuples():
    pool = trainers_by_club.get(c.home_club_id, all_trainers)
    main_trainer = int(rng.choice(pool))
    buy_date = c.signup_date
    n_buys = 0
    while buy_date <= TODAY and n_buys < 4:
        if n_buys == 0 and rng.random() < 0.4:
            pkg = pkgs.iloc[0]  # many clients start with the trial
        else:
            pkg = pkgs.iloc[int(rng.choice(5, p=PKG_P))]
        discount = float(rng.choice([0, 0.05, 0.10, 0.15, 0.20], p=[0.55, 0.15, 0.15, 0.10, 0.05]))
        net = round(float(pkg["list_price_aed"]) * (1 - discount), 2)
        pid += 1
        purchases.append((pid, c.client_id, int(pkg["package_type_id"]), main_trainer,
                          c.home_club_id, buy_date, float(pkg["list_price_aed"]), discount, net))

        pay_id += 1
        payments.append((pay_id, pid, net, buy_date,
                         str(rng.choice(["card", "cash", "bank_transfer"], p=[0.75, 0.10, 0.15])),
                         str(rng.choice(["paid", "refunded"], p=[0.97, 0.03]))))

        n = int(pkg["sessions_included"])
        offsets = np.sort(rng.integers(1, int(pkg["validity_days"]) + 1, n))
        for off in offsets:
            sched = buy_date + pd.Timedelta(days=int(off), hours=int(rng.integers(6, 21)))
            booked_at = max(buy_date, sched - pd.Timedelta(days=int(rng.integers(1, 15))))
            trainer = main_trainer if rng.random() < 0.85 else int(rng.choice(pool))
            if sched > TODAY:
                status = "booked"
            else:
                status = str(rng.choice(["delivered", "cancelled", "no_show"], p=[0.78, 0.15, 0.07]))
            sid += 1
            sessions.append((sid, pid, c.client_id, trainer, c.home_club_id,
                             booked_at, sched, 60, status))

        n_buys += 1
        if rng.random() < 0.55:  # renewal
            buy_date = buy_date + pd.Timedelta(days=int(int(pkg["validity_days"]) * rng.uniform(0.6, 1.1)))
        else:
            break

cols_p = ["purchase_id", "client_id", "package_type_id", "trainer_id", "club_id",
          "purchase_date", "list_price_aed", "discount_pct", "net_price_aed"]
cols_s = ["session_id", "purchase_id", "client_id", "trainer_id", "club_id",
          "booked_at", "scheduled_at", "duration_min", "status"]
cols_pay = ["payment_id", "purchase_id", "amount_aed", "payment_date", "method", "status"]

for name, rows, cols in [("purchases", purchases, cols_p), ("sessions", sessions, cols_s),
                         ("payments", payments, cols_pay)]:
    pd.DataFrame(rows, columns=cols).to_csv(raw / f"{name}.csv", index=False)
clients.to_csv(raw / "clients.csv", index=False)

for n in ["clients", "purchases", "sessions", "payments"]:
    print(n, pd.read_csv(raw / f"{n}.csv").shape)