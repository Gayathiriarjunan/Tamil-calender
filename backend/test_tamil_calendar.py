from tamil_panchanga_calendar import TamilCalendar


def get_tamil_date(date_string):
    result = TamilCalendar.from_date(date_string)
    return result.as_dict()


if __name__ == "__main__":
    dates = [
        "2026-10-14",
        "2027-01-15",
        "2028-01-15",
        "2029-01-15",
        "2030-01-15",
    ]

    for date_string in dates:
        try:
            result = get_tamil_date(date_string)

            print("\nGregorian date:", date_string)
            print("Tamil date:", result["formatted"])
            print("Tamil month:", result["month_name_tamil"])
            print("Tamil year:", result["year_name_tamil"])
            print("Tamil weekday:", result["weekday_name_tamil"])
            print("Thiruvalluvar year:", result["thiruvalluvar_year"])

        except Exception as error:
            print(f"Error for {date_string}: {error}")
