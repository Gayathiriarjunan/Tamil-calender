import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from app import create_app

def setup_client():
    app = create_app({"TESTING": True, "MONGO_URI": "", "MONGO_DB": "test"})
    return app.test_client()

def test_health():
    response = setup_client().get("/api/v1/health")
    assert response.status_code == 200
    assert response.json["ok"] is True

def test_day_bad_date():
    response = setup_client().get("/api/v1/calendar/day?date=not-a-date")
    assert response.status_code == 400

def test_month_invalid_month():
    response = setup_client().get("/api/v1/calendar/month?year=2027&month=13")
    assert response.status_code == 400

def test_locations():
    response = setup_client().get("/api/v1/locations")
    assert response.status_code == 200
    assert any(x["id"] == "chennai" for x in response.json["data"])

def test_festival_dates_are_not_fabricated():
    response = setup_client().get("/api/v1/festivals/upcoming")
    assert response.status_code == 200
    assert all(x["date"] is None for x in response.json["data"])
