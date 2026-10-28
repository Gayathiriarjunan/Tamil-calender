import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    DEBUG = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    PORT = int(os.getenv("PORT", "5000"))
    MONGO_URI = os.getenv("MONGO_URI", "").strip()
    MONGO_DB = os.getenv("MONGO_DB", "tamil_nallkaati")
    CORS_ORIGINS = [x.strip() for x in os.getenv(
        "CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000"
    ).split(",") if x.strip()]
