from flask import Blueprint, jsonify
from app.repositories.calendar_repository import LOCATIONS
location_bp = Blueprint("locations", __name__)

@location_bp.get("/locations")
def locations():
    return jsonify({"ok": True, "data": list(LOCATIONS.values())}), 200
