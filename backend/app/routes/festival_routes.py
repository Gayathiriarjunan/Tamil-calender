from datetime import date

import requests
from flask import Blueprint, jsonify, request

festival_bp = Blueprint("festivals", __name__)

FESTIVAL_API_URL = (
    "https://shastrapanchangam.com/api/v1/festivals.json"
)


def fetch_festival_data():
    response = requests.get(
        FESTIVAL_API_URL,
        timeout=15,
    )

    response.raise_for_status()

    return response.json()


@festival_bp.get("/festivals/year")
def by_year():
    try:
        year = int(request.args.get("year", date.today().year))

        if not 1900 <= year <= 2100:
            raise ValueError(
                "Year must be between 1900 and 2100."
            )

        festival_data = fetch_festival_data()

        # Keep the original source response intact until its
        # actual JSON structure has been verified.
        return jsonify({
            "ok": True,
            "year": year,
            "data_status": "connected",
            "source": "Shastra Panchangam",
            "data": festival_data,
        }), 200

    except ValueError as exc:
        return jsonify({
            "ok": False,
            "error": str(exc),
        }), 400

    except requests.RequestException:
        return jsonify({
            "ok": False,
            "error": "Festival data service is unavailable.",
        }), 502

    except Exception:
        return jsonify({
            "ok": False,
            "error": "Unable to retrieve festival data.",
        }), 500


@festival_bp.get("/festivals/upcoming")
def upcoming():
    try:
        festival_data = fetch_festival_data()

        return jsonify({
            "ok": True,
            "data_status": "connected",
            "source": "Shastra Panchangam",
            "data": festival_data,
        }), 200

    except requests.RequestException:
        return jsonify({
            "ok": False,
            "error": "Festival data service is unavailable.",
        }), 502

    except Exception:
        return jsonify({
            "ok": False,
            "error": "Unable to retrieve festival data.",
        }), 500