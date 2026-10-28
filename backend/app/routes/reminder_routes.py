from flask import Blueprint, jsonify, request
from uuid import uuid4
from datetime import datetime

reminder_bp = Blueprint("reminders", __name__)
# Development-only in-memory store. Use MongoDB plus authentication for production.
_REMINDERS = {}

@reminder_bp.post("/reminders")
def create_reminder():
    body = request.get_json(silent=True) or {}
    title = str(body.get("title", "")).strip()
    date_text = str(body.get("date", "")).strip()
    if not title or not date_text:
        return jsonify({"ok": False, "error": "title and date are required"}), 400
    try:
        datetime.fromisoformat(date_text)
    except ValueError:
        return jsonify({"ok": False, "error": "date must be ISO format YYYY-MM-DD or ISO datetime"}), 400
    item = {"id": str(uuid4()), "title": title[:120], "date": date_text,
            "notes": str(body.get("notes", ""))[:1000]}
    _REMINDERS[item["id"]] = item
    return jsonify({"ok": True, "data": item}), 201

@reminder_bp.get("/reminders")
def list_reminders():
    return jsonify({"ok": True, "data": list(_REMINDERS.values())}), 200

@reminder_bp.put("/reminders/<reminder_id>")
def update_reminder(reminder_id):
    if reminder_id not in _REMINDERS:
        return jsonify({"ok": False, "error": "reminder not found"}), 404
    body = request.get_json(silent=True) or {}
    for key in ("title", "date", "notes"):
        if key in body:
            _REMINDERS[reminder_id][key] = str(body[key])[:1000]
    return jsonify({"ok": True, "data": _REMINDERS[reminder_id]}), 200

@reminder_bp.delete("/reminders/<reminder_id>")
def delete_reminder(reminder_id):
    if _REMINDERS.pop(reminder_id, None) is None:
        return jsonify({"ok": False, "error": "reminder not found"}), 404
    return jsonify({"ok": True, "message": "deleted"}), 200
