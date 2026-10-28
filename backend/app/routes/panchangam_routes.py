import json
from datetime import date, datetime
from pathlib import Path

from flask import Blueprint, current_app, jsonify, request

panchangam_bp = Blueprint(
    "panchangam",
    __name__,
    url_prefix="/api/v1",
)
# backend/panchangam_data/
DATA_DIR = Path(__file__).resolve().parents[2] / "panchangam_data"


def load_year_data(year):
    """Load a year's downloaded Panchangam JSON file."""
    file_path = DATA_DIR / f"panchangam_{year}.json"

    if not file_path.exists():
        return None

    try:
        with file_path.open("r", encoding="utf-8") as file:
            return json.load(file)
    except (OSError, json.JSONDecodeError):
        current_app.logger.exception(
            "Unable to read Panchangam file: %s", file_path
        )
        return None


def extract_days(payload):
    """Support common JSON response structures."""
    if isinstance(payload, list):
        return payload

    if not isinstance(payload, dict):
        return []

    # The API may return a list directly or wrap it in an object.
    for key in ("days", "data", "results", "items"):
        value = payload.get(key)

        if isinstance(value, list):
            return value

        if isinstance(value, dict):
            nested = extract_days(value)
            if nested:
                return nested

    # A single-day response has a date field.
    if payload.get("date"):
        return [payload]

    return []


def find_day(date_text):
    """Find a requested date in the downloaded yearly files."""
    try:
        requested_date = date.fromisoformat(date_text)
    except (ValueError, TypeError):
        return None, "Date must use YYYY-MM-DD format."

    payload = load_year_data(requested_date.year)

    if payload is None:
        return None, (
            f"No downloaded Panchangam file is available for "
            f"{requested_date.year}."
        )

    for item in extract_days(payload):
        if not isinstance(item, dict):
            continue

        # Some API responses wrap the daily fields in a 'day' object.
        day_data = item.get("day", item)

        if isinstance(day_data, dict):
            if day_data.get("date") == requested_date.isoformat():
                return day_data, None

    return None, f"No Panchangam record found for {date_text}."


@panchangam_bp.get("/panchangam/day")
def panchangam_day():
    date_text = request.args.get("date", date.today().isoformat())

    try:
        date.fromisoformat(date_text)
    except ValueError:
        return jsonify({
            "ok": False,
            "error": "Invalid date. Use YYYY-MM-DD.",
        }), 400

    day, error = find_day(date_text)

    if day is None:
        return jsonify({
            "ok": False,
            "error": error,
        }), 404

    return jsonify({
        "ok": True,
        "data": day,
    })


@panchangam_bp.get("/panchangam/month")
def panchangam_month():
    try:
        year = int(request.args.get("year", date.today().year))
        month = int(request.args.get("month", date.today().month))

        if not 1 <= month <= 12:
            raise ValueError("Month must be between 1 and 12.")

        first_day = date(year, month, 1)

    except (ValueError, TypeError) as exc:
        return jsonify({
            "ok": False,
            "error": str(exc),
        }), 400

    payload = load_year_data(year)

    if payload is None:
        return jsonify({
            "ok": False,
            "error": f"No downloaded data for {year}.",
        }), 404

    records = []

    for item in extract_days(payload):
        if not isinstance(item, dict):
            continue

        day_data = item.get("day", item)

        if not isinstance(day_data, dict):
            continue

        text_date = day_data.get("date", "")

        if text_date.startswith(f"{year:04d}-{month:02d}-"):
            records.append(day_data)

    records.sort(key=lambda item: item.get("date", ""))

    return jsonify({
        "ok": True,
        "year": year,
        "month": month,
        "data": records,
    })


@panchangam_bp.get("/panchangam/year")
def panchangam_year():
    try:
        year = int(request.args.get("year", date.today().year))
    except (ValueError, TypeError):
        return jsonify({
            "ok": False,
            "error": "Year must be a number.",
        }), 400

    payload = load_year_data(year)

    if payload is None:
        return jsonify({
            "ok": False,
            "error": f"No downloaded data for {year}.",
        }), 404

    return jsonify({
        "ok": True,
        "year": year,
        "data": extract_days(payload),
    })
