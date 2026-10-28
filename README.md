# Tamil Nallkaati — தமிழ் நாள்காட்டி

A beginner-friendly starter project for a Tamil-first calendar app. It includes a Flutter mobile UI, a Flask REST API, optional MongoDB Atlas persistence, demo calendar/festival data, tests, and setup documentation.

> **Calendar accuracy notice:** included dates, festival entries, and Panchangam values are clearly marked as demo/unverified. They are for UI/API development only and must not be treated as an authoritative Nithya Calendar or religious calendar. Do not publish calculated timings until validated against a licensed, documented calendar/astronomy source and a Tamil calendar domain expert.

## Folder structure

```text
tamil_nallkaati/
├── frontend/                    # Flutter + Dart Android app
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── app/theme.dart
│       ├── screens/home_screen.dart
│       ├── screens/calendar_screen.dart
│       ├── screens/festivals_screen.dart
│       ├── screens/panchangam_screen.dart
│       ├── services/api_service.dart
│       └── widgets/kolam_badge.dart
├── backend/                     # Python Flask API
│   ├── app.py
│   ├── config.py
│   ├── requirements.txt
│   ├── .env.example
│   ├── app/routes/
│   ├── app/services/
│   ├── app/repositories/
│   ├── scripts/seed_demo_data.py
│   └── tests/
├── docs/
│   └── API_EXAMPLES.md
├── postman/Tamil_Nallkaati.postman_collection.json
└── Tamil_Nallkaati_Documentation.docx
```

## Prerequisites

- Flutter SDK (stable channel) and Android Studio / Android SDK
- Python 3.10 or newer
- VS Code (recommended)
- MongoDB Atlas account is optional for the demo; the API can run with demo data without MongoDB.

## Run the backend (Windows PowerShell)

```powershell
cd backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item .env.example .env
python app.py
```

API health check: `http://127.0.0.1:5000/api/v1/health`

If PowerShell blocks activation, run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` in that terminal, then activate again.

## Run Flutter frontend

Open a second terminal:

```powershell
cd frontend
flutter pub get
flutter devices
flutter run
```

For an Android emulator, the app uses `http://10.0.2.2:5000` as the backend address. For a physical phone, change `apiBaseUrl` in `lib/services/api_service.dart` to your laptop's LAN IP, for example `http://192.168.1.10:5000`, and keep the phone/laptop on the same Wi-Fi. Allow Python through Windows Firewall if prompted. Do not use local HTTP/LAN URLs in production.

## Optional MongoDB Atlas

1. Create a MongoDB Atlas cluster and database user.
2. Add your current IP address to Atlas Network Access.
3. Copy the connection string into `backend/.env` as `MONGO_URI`.
4. Set `MONGO_DB=tamil_nallkaati`.
5. Keep `.env` out of Git. Never put database credentials in Flutter.
6. Restart Flask. The app uses MongoDB when configured; otherwise, it returns demo data.

## Main demo endpoints

- `GET /api/v1/health`
- `GET /api/v1/locations`
- `GET /api/v1/calendar/day?date=2027-04-14&location=chennai`
- `GET /api/v1/calendar/month?year=2027&month=4&location=chennai`
- `GET /api/v1/panchangam/day?date=2027-04-14&location=chennai`
- `GET /api/v1/festivals/upcoming?location=chennai`
- `GET /api/v1/festivals/year?year=2027&location=chennai`

## Notes about Nithya Calendar

Use Nithya Calendar as a **visual/feature reference only** unless you have permission and a suitable data licence to use its calendar content. This starter includes original demo UI/data and does not copy Nithya Calendar's proprietary data or claim date-by-date parity. Compare the app with an authorized Nithya Calendar edition before validating real dates.

## Next phases

1. Confirm the UI and user flow.
2. Choose and license a reliable Tamil Panchangam/calendar calculation source.
3. Implement/validate Tamil month/year, tithi, nakshatra and location-specific astronomical timings.
4. Add reminder persistence, authentication, notification scheduling and production hardening.
5. Run tests against independently verified dates before publishing.
