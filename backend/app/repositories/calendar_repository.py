from datetime import date
from pymongo import MongoClient
from pymongo.errors import PyMongoError

LOCATIONS = {
    "chennai": {"id": "chennai", "name_ta": "சென்னை", "name_en": "Chennai",
                "latitude": 13.0827, "longitude": 80.2707, "timezone": "Asia/Kolkata"},
    "salem": {"id": "salem", "name_ta": "சேலம்", "name_en": "Salem",
              "latitude": 11.6643, "longitude": 78.1460, "timezone": "Asia/Kolkata"},
    "coimbatore": {"id": "coimbatore", "name_ta": "கோயம்புத்தூர்", "name_en": "Coimbatore",
                   "latitude": 11.0168, "longitude": 76.9558, "timezone": "Asia/Kolkata"},
    "madurai": {"id": "madurai", "name_ta": "மதுரை", "name_en": "Madurai",
                "latitude": 9.9252, "longitude": 78.1198, "timezone": "Asia/Kolkata"},
    "tiruchirappalli": {"id": "tiruchirappalli", "name_ta": "திருச்சிராப்பள்ளி", "name_en": "Tiruchirappalli",
                        "latitude": 10.7905, "longitude": 78.7047, "timezone": "Asia/Kolkata"},
    "tirunelveli": {"id": "tirunelveli", "name_ta": "திருநெல்வேலி", "name_en": "Tirunelveli",
                    "latitude": 8.7139, "longitude": 77.7567, "timezone": "Asia/Kolkata"},
    "erode": {"id": "erode", "name_ta": "ஈரோடு", "name_en": "Erode",
              "latitude": 11.3410, "longitude": 77.7172, "timezone": "Asia/Kolkata"},
    "thanjavur": {"id": "thanjavur", "name_ta": "தஞ்சாவூர்", "name_en": "Thanjavur",
                  "latitude": 10.7870, "longitude": 79.1378, "timezone": "Asia/Kolkata"},
    "vellore": {"id": "vellore", "name_ta": "வேலூர்", "name_en": "Vellore",
                "latitude": 12.9165, "longitude": 79.1325, "timezone": "Asia/Kolkata"},
}

class CalendarRepository:
    def __init__(self, mongo_uri="", db_name="tamil_nallkaati"):
        self.client = None
        self.db = None
        if mongo_uri:
            try:
                client = MongoClient(mongo_uri, serverSelectionTimeoutMS=2500)
                client.admin.command("ping")
                self.client = client
                self.db = client[db_name]
                self.db.calendar_days.create_index([("gregorian_date", 1), ("location_id", 1)], unique=True)
                self.db.festivals.create_index([("year", 1), ("date", 1)])
            except PyMongoError:
                self.client = None
                self.db = None

    def get_day(self, date_text, location_id):
        if self.db is not None:
            doc = self.db.calendar_days.find_one({"gregorian_date": date_text, "location_id": location_id}, {"_id": 0})
            if doc:
                doc["data_status"] = doc.get("data_status", "unverified")
                return doc
        d = date.fromisoformat(date_text)
        return {
            "gregorian_date": date_text,
            "location_id": location_id,
            "weekday_ta": ["திங்கட்கிழமை", "செவ்வாய்க்கிழமை", "புதன்கிழமை", "வியாழக்கிழமை", "வெள்ளிக்கிழமை", "சனிக்கிழமை", "ஞாயிற்றுக்கிழமை"][d.weekday()],
            "tamil_date": "தமிழ் தேதி — சரிபார்க்கப்படவில்லை",
            "tamil_month": None,
            "tamil_year": None,
            "sunrise": None,
            "sunset": None,
            "festival_ids": [],
            "data_status": "demo_unverified",
            "note_ta": "இது demo பதிவு; அதிகாரப்பூர்வ நாள்காட்டி தரவு அல்ல."
        }

    def get_festivals(self, year=None):
        if self.db is not None:
            query = {"year": year} if year else {}
            docs = list(self.db.festivals.find(query, {"_id": 0}).sort("date", 1).limit(100))
            if docs:
                return docs
        # No dates are assigned here because festival dates vary by year/tradition.
        return [
            {"name_ta": name, "date": None, "year": year, "verification_status": "unverified",
             "description_ta": description, "source": None}
            for name, description in [
                ("தமிழ் புத்தாண்டு", "தமிழ் ஆண்டின் தொடக்க விழா."),
                ("பொங்கல்", "அறுவடை மற்றும் நன்றி செலுத்தும் திருநாள்."),
                ("தைப்பூசம்", "முருக வழிபாட்டுடன் தொடர்புடைய விழா."),
                ("மகா சிவராத்திரி", "சிவபெருமானை வழிபடும் இரவு."),
                ("பங்குனி உத்திரம்", "பங்குனி மாதத்தில் கடைப்பிடிக்கப்படும் விழா."),
                ("ஆடி பெருக்கு", "நீர்வளத்துடன் தொடர்புடைய பாரம்பரிய நாள்."),
                ("விநாயகர் சதுர்த்தி", "விநாயகர் வழிபாட்டு விழா."),
                ("நவராத்திரி", "ஒன்பது நாள் வழிபாட்டு விழா."),
                ("தீபாவளி", "ஒளித் திருநாள்."),
                ("கார்த்திகை தீபம்", "தீப ஒளியுடன் கொண்டாடப்படும் விழா."),
                ("வைகுண்ட ஏகாதசி", "வைணவ மரபில் முக்கியமான நாள்."),
            ]
        ]
