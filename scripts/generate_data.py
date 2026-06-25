"""
Generate the small CSV dataset used by the Neo4j fraud demo.

The repository already includes generated CSVs in data/. Run this script only if
you want to recreate them.
"""

from __future__ import annotations

import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"


FILES = {
    "people.csv": [
        ["person_id", "name", "risk_score", "device_id", "phone_id", "address_id"],
        ["P001", "Alice Martin", 85, "D001", "PH001", "AD001"],
        ["P002", "Bob Chen", 78, "D001", "PH001", "AD001"],
        ["P003", "Carol Singh", 92, "D002", "PH002", "AD002"],
        ["P004", "Dave Novak", 65, "D003", "PH003", "AD003"],
        ["P005", "Eve Carter", 88, "D004", "PH004", "AD004"],
        ["P006", "Frank Diaz", 72, "D005", "PH005", "AD005"],
        ["P007", "Grace Kim", 80, "D006", "PH005", "AD005"],
        ["P008", "Hannah Lee", 20, "D007", "PH006", "AD006"],
    ],
    "accounts.csv": [
        ["account_id", "person_id", "account_type", "status", "opened_date"],
        ["A100", "P001", "checking", "active", "2024-01-12"],
        ["A101", "P001", "savings", "active", "2024-02-05"],
        ["A200", "P002", "checking", "active", "2024-01-18"],
        ["A300", "P003", "checking", "flagged", "2024-03-01"],
        ["A400", "P004", "checking", "active", "2024-03-04"],
        ["A500", "P005", "checking", "flagged", "2024-03-07"],
        ["A600", "P006", "checking", "active", "2024-04-02"],
        ["A700", "P007", "checking", "flagged", "2024-04-03"],
        ["A800", "P008", "checking", "active", "2024-05-10"],
    ],
    "transactions.csv": [
        ["transaction_id", "from_account_id", "to_account_id", "amount", "timestamp", "channel", "merchant_id"],
        ["T001", "A100", "A200", "250.00", "2026-04-01T09:15:00", "transfer", ""],
        ["T002", "A200", "A101", "180.00", "2026-04-01T10:30:00", "transfer", ""],
        ["T003", "A300", "A400", "900.00", "2026-04-02T11:00:00", "transfer", ""],
        ["T004", "A400", "A500", "875.00", "2026-04-02T11:12:00", "transfer", ""],
        ["T005", "A500", "A300", "850.00", "2026-04-02T11:25:00", "transfer", ""],
        ["T006", "A600", "A700", "600.00", "2026-04-03T14:20:00", "transfer", ""],
        ["T007", "A700", "A300", "550.00", "2026-04-03T15:10:00", "transfer", ""],
        ["T008", "A800", "A100", "45.00", "2026-04-05T08:45:00", "transfer", ""],
        ["T009", "A101", "A800", "30.00", "2026-04-05T12:00:00", "transfer", ""],
        ["T010", "A700", "", "1200.00", "2026-04-06T16:45:00", "card", "M001"],
        ["T011", "A200", "", "65.50", "2026-04-06T18:10:00", "card", "M002"],
        ["T012", "A300", "", "400.00", "2026-04-07T09:35:00", "card", "M003"],
    ],
    "devices.csv": [
        ["device_id", "device_type", "label"],
        ["D001", "mobile", "Shared iPhone 13"],
        ["D002", "laptop", "Carol laptop"],
        ["D003", "mobile", "Dave Android"],
        ["D004", "desktop", "Eve desktop"],
        ["D005", "mobile", "Frank Android"],
        ["D006", "mobile", "Grace iPhone"],
        ["D007", "laptop", "Hannah laptop"],
    ],
    "phone_numbers.csv": [
        ["phone_id", "phone_number"],
        ["PH001", "+1-555-0101"],
        ["PH002", "+1-555-0102"],
        ["PH003", "+1-555-0103"],
        ["PH004", "+1-555-0104"],
        ["PH005", "+1-555-0199"],
        ["PH006", "+1-555-0106"],
    ],
    "addresses.csv": [
        ["address_id", "street", "city", "country"],
        ["AD001", "10 Market Street", "Boston", "USA"],
        ["AD002", "21 Pine Road", "Chicago", "USA"],
        ["AD003", "88 Lake Avenue", "Denver", "USA"],
        ["AD004", "7 River Lane", "Seattle", "USA"],
        ["AD005", "44 Union Square", "New York", "USA"],
        ["AD006", "15 Hill Street", "Austin", "USA"],
    ],
    "merchants.csv": [
        ["merchant_id", "name", "category"],
        ["M001", "Fast Electronics", "electronics"],
        ["M002", "Campus Cafe", "food"],
        ["M003", "Crypto Voucher Store", "financial_services"],
    ],
}


def write_csv(filename: str, rows: list[list[object]]) -> None:
    DATA_DIR.mkdir(exist_ok=True)
    with (DATA_DIR / filename).open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerows(rows)


def main() -> None:
    for filename, rows in FILES.items():
        write_csv(filename, rows)
    print(f"Wrote {len(FILES)} CSV files to {DATA_DIR}")


if __name__ == "__main__":
    main()
