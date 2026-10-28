# API examples

Base URL for local backend: `http://127.0.0.1:5000`

## Health
`GET /api/v1/health`

```json
{"ok": true, "service": "Tamil Nallkaati API", "calendar_data": "demo_unverified"}
```

## Day
`GET /api/v1/calendar/day?date=2027-04-14&location=chennai`

Response is a demo shell. `tamil_date`, sunrise, sunset and festival references are not authoritative until a validated calendar engine/data source is integrated.

## Month
`GET /api/v1/calendar/month?year=2027&month=4&location=chennai`

Returns one record per Gregorian day. Records are marked demo/unverified.

## Panchangam
`GET /api/v1/panchangam/day?date=2027-04-14&location=chennai`

Unsupported values are returned as `null`, not invented.

## Festivals
`GET /api/v1/festivals/upcoming?location=chennai`

The starter returns festival names/descriptions without assigning dates. Add annual dates only after verification and record source/provenance.

## Reminder
POST `/api/v1/reminders`

```json
{"title":"குடும்ப நிகழ்வு","date":"2027-04-14","notes":"demo"}
```

The reminder store is in-memory for development only; records disappear when Flask restarts. Production requires persistent storage, authentication, authorization and notification scheduling.
