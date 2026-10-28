from flask import Blueprint, current_app, jsonify, request

calendar_bp = Blueprint("calendar", __name__)


@calendar_bp.get("/calendar/day")
def calendar_day():
    try:
        date_text = request.args.get("date")

        if not date_text:
            from datetime import date
            date_text = date.today().isoformat()

        location = request.args.get(
            "location",
            "chennai"
        )

        service = current_app.extensions["calendar_service"]

        data = service.day(
            date_text,
            location
        )

        return jsonify({
            "ok": True,
            "data": data
        }), 200

    except ValueError as exc:
        return jsonify({
            "ok": False,
            "error": str(exc)
        }), 400

    except Exception:
        current_app.logger.exception(
            "Failed to calculate Tamil calendar date"
        )

        return jsonify({
            "ok": False,
            "error": "Unable to calculate calendar date."
        }), 500


@calendar_bp.get("/calendar/month")
def calendar_month():
    try:
        year = int(request.args.get("year", "2026"))
        month = int(request.args.get("month", "1"))

        location = request.args.get(
            "location",
            "chennai"
        )

        service = current_app.extensions["calendar_service"]

        data = service.month(
            year,
            month,
            location
        )

        return jsonify({
            "ok": True,
            "data": data
        }), 200

    except (ValueError, TypeError) as exc:
        return jsonify({
            "ok": False,
            "error": str(exc)
        }), 400

    except Exception:
        current_app.logger.exception(
            "Failed to calculate calendar month"
        )

        return jsonify({
            "ok": False,
            "error": "Unable to calculate calendar month."
        }), 500


@calendar_bp.get("/calendar/year")
def calendar_year():
    try:
        year = int(request.args.get("year", "2026"))

        if not 1900 <= year <= 2100:
            raise ValueError(
                "Year must be between 1900 and 2100."
            )

        location = request.args.get(
            "location",
            "chennai"
        )

        service = current_app.extensions["calendar_service"]

        months = []

        for month in range(1, 13):
            months.append(
                service.month(
                    year,
                    month,
                    location
                )
            )

        return jsonify({
            "ok": True,
            "year": year,
            "location": location,
            "data": months,
            "data_status": "calculated"
        }), 200

    except (ValueError, TypeError) as exc:
        return jsonify({
            "ok": False,
            "error": str(exc)
        }), 400

    except Exception:
        current_app.logger.exception(
            "Failed to calculate calendar year"
        )

        return jsonify({
            "ok": False,
            "error": "Unable to calculate calendar year."
        }), 500