from flask import Flask, jsonify
from flask_cors import CORS
from config import Config
from app.repositories.calendar_repository import CalendarRepository
from app.services.calendar_service import CalendarService
from app.routes.calendar_routes import calendar_bp
from app.routes.panchangam_routes import panchangam_bp
from app.routes.festival_routes import festival_bp
from app.routes.location_routes import location_bp
from app.routes.reminder_routes import reminder_bp

def create_app(test_config=None):
    app = Flask(__name__)
    app.config.from_object(Config)
    if test_config:
        app.config.update(test_config)
    CORS(app, resources={r"/api/*": {"origins": "*"}})  # Restrict origins before production.
    repository = CalendarRepository(app.config.get("MONGO_URI", ""), app.config.get("MONGO_DB", "tamil_nallkaati"))
    app.extensions["calendar_repository"] = repository
    app.extensions["calendar_service"] = CalendarService(repository)
    prefix = "/api/v1"
    app.register_blueprint(calendar_bp, url_prefix=prefix)
    app.register_blueprint(panchangam_bp, url_prefix=prefix)
    app.register_blueprint(festival_bp, url_prefix=prefix)
    app.register_blueprint(location_bp, url_prefix=prefix)
    app.register_blueprint(reminder_bp, url_prefix=prefix)

    @app.get("/api/v1/health")
    def health():
        return jsonify({"ok": True, "service": "Tamil Nallkaati API", "calendar_data": "demo_unverified"}), 200

    @app.errorhandler(404)
    def not_found(_):
        return jsonify({"ok": False, "error": "endpoint not found"}), 404

    return app

