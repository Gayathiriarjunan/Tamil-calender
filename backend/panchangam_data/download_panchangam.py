import json
import requests
from pathlib import Path
from datetime import date

BASE_URL = "https://shastrapanchangam.com/api/v1/range"
OUTPUT_DIR = Path(__file__).parent
CITY = "chennai"

for year in range(2026, 2031):
    start = date(year, 1, 1)
    end = date(year, 12, 31)
    days = (end - start).days + 1

    params = {
        "from": start.isoformat(),
        "days": days,
    }

    url = f"{BASE_URL}/{CITY}.json"

    try:
        response = requests.get(url, params=params, timeout=60)
        response.raise_for_status()

        data = response.json()

        output_file = OUTPUT_DIR / f"panchangam_{year}.json"

        with output_file.open("w", encoding="utf-8") as file:
            json.dump(data, file, ensure_ascii=False, indent=2)

        print(f"Downloaded {year}: {output_file}")

    except (requests.RequestException, ValueError) as error:
        print(f"Failed to download {year}: {error}")
