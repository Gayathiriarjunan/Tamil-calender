
from datetime import date, timedelta
from tamil_panchanga_calendar import TamilCalendar


class CalendarService:

    def __init__(self, repository):
        self.repository = repository

    @staticmethod
    def _parse_date(date_text):
        try:
            selected_date = date.fromisoformat(date_text)
        except (TypeError, ValueError):
            raise ValueError("Date must use YYYY-MM-DD format.")

        if not date(1900, 1, 1) <= selected_date <= date(2100, 12, 31):
            raise ValueError(
                "Supported dates are from 1900 to 2100."
            )

        return selected_date

    def day(self, date_text, location="chennai"):
        selected_date = self._parse_date(date_text)

        result = TamilCalendar.from_date(
            selected_date.isoformat()
        )

        tamil_data = result.as_dict()

        return {
            **tamil_data,
            "gregorian_date": selected_date.isoformat(),
            "location": location,
            "data_source": "tamil-panchanga-calendar",
            "data_status": "calculated",
        }

    def month(self, year, month, location="chennai"):
        if not 1900 <= year <= 2100:
            raise ValueError("Year must be between 1900 and 2100.")

        if not 1 <= month <= 12:
            raise ValueError("Month must be between 1 and 12.")

        current_date = date(year, month, 1)

        if month == 12:
            next_month = date(year + 1, 1, 1)
        else:
            next_month = date(year, month + 1, 1)

        days = []

        while current_date < next_month:
            days.append(
                self.day(
                    current_date.isoformat(),
                    location
                )
            )

            current_date += timedelta(days=1)

        return {
            "year": year,
            "gregorian_month": month,
            "location": location,
            "days": days,
            "data_status": "calculated",
        }
