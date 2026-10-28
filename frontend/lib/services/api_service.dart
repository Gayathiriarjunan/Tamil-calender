import 'dart:convert';

import 'package:http/http.dart' as http;

/// API service for Tamil Nallkaati.
///
/// Physical Android phone:
/// Use your computer's Wi-Fi IPv4 address.
///
/// Android emulator:
/// Use http://10.0.2.2:5000
///
/// Flutter Web on the same computer:
/// Use http://127.0.0.1:5000
class ApiService {
  static const String apiBaseUrl = 'http://192.168.0.6:5000';
  static const String defaultLocation = 'chennai';

  /// Sends a GET request and returns the JSON response.
  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$apiBaseUrl$path');

    late final http.Response response;

    try {
      response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception(
        'Cannot connect to the Flask backend. '
        'Check the backend server, IP address, Wi-Fi, '
        'and firewall. Details: $e',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'API request failed with HTTP ${response.statusCode}: '
        '${response.body}',
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException(
        'The backend did not return valid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid API response: expected a JSON object.',
      );
    }

    if (decoded['ok'] == false) {
      throw Exception(
        decoded['error'] ??
            decoded['message'] ??
            'The API request failed.',
      );
    }

    return decoded;
  }

  /// Gets today's Tamil calendar data.
  Future<Map<String, dynamic>> getToday({
    String location = defaultLocation,
  }) {
    return getCalendarDay(
      DateTime.now(),
      location: location,
    );
  }

  /// Gets Tamil calendar data for a particular date.
  Future<Map<String, dynamic>> getCalendarDay(
    DateTime date, {
    String location = defaultLocation,
  }) {
    final query = _buildQuery({
      'date': _formatDate(date),
      'location': location,
    });

    return getJson('/api/v1/calendar/day?$query');
  }

  /// Gets calendar data for a Gregorian month.
  Future<Map<String, dynamic>> getCalendarMonth({
    required int year,
    required int month,
    String location = defaultLocation,
  }) {
    _validateYear(year);

    if (month < 1 || month > 12) {
      throw ArgumentError(
        'Month must be between 1 and 12.',
      );
    }

    final query = _buildQuery({
      'year': year.toString(),
      'month': month.toString(),
      'location': location,
    });

    return getJson('/api/v1/calendar/month?$query');
  }

  /// Gets calendar data for a Gregorian year.
  Future<Map<String, dynamic>> getCalendarYear(
    int year, {
    String location = defaultLocation,
  }) {
    _validateYear(year);

    final query = _buildQuery({
      'year': year.toString(),
      'location': location,
    });

    return getJson('/api/v1/calendar/year?$query');
  }

  /// Gets Panchangam data for a particular date.
  Future<Map<String, dynamic>> getPanchangam(
    DateTime date, {
    String location = defaultLocation,
  }) {
    final query = _buildQuery({
      'date': _formatDate(date),
      'location': location,
    });

    return getJson('/api/v1/panchangam/day?$query');
  }

  /// Gets upcoming festivals.
  Future<Map<String, dynamic>> getUpcomingFestivals({
    String location = defaultLocation,
  }) {
    final query = _buildQuery({
      'location': location,
    });

    return getJson('/api/v1/festivals/upcoming?$query');
  }

  /// Gets festival data for a particular year.
  Future<Map<String, dynamic>> getFestivalsForYear(
    int year, {
    String location = defaultLocation,
  }) {
    _validateYear(year);

    final query = _buildQuery({
      'year': year.toString(),
      'location': location,
    });

    return getJson('/api/v1/festivals/year?$query');
  }

  /// Formats dates as YYYY-MM-DD.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  /// Creates an encoded URL query string.
  String _buildQuery(Map<String, String> parameters) {
    return parameters.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
  }

  /// Validates the supported year range.
  void _validateYear(int year) {
    if (year < 1900 || year > 2100) {
      throw ArgumentError(
        'Year must be between 1900 and 2100.',
      );
    }
  }
}