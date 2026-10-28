"""Optional demo seed script. Does not generate religious dates or Panchangam timings."""
import os
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()
uri = os.getenv("MONGO_URI", "").strip()
if not uri:
    raise SystemExit("Set MONGO_URI in backend/.env first.")
client = MongoClient(uri)
db = client[os.getenv("MONGO_DB", "tamil_nallkaati")]
db.calendar_days.create_index([("gregorian_date", 1), ("location_id", 1)], unique=True)
db.festivals.create_index([("year", 1), ("date", 1)])
db.locations.create_index("id", unique=True)
locations = [
    {"id": "chennai", "name_ta": "சென்னை", "latitude": 13.0827, "longitude": 80.2707, "timezone": "Asia/Kolkata"},
    {"id": "salem", "name_ta": "சேலம்", "latitude": 11.6643, "longitude": 78.1460, "timezone": "Asia/Kolkata"},
]
for location in locations:
    db.locations.update_one({"id": location["id"]}, {"$set": location}, upsert=True)
print("Indexes and location demo records created. No calendar or festival dates were fabricated.")
