import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../services/api_service.dart';

const weekdays = ['ஞா', 'தி', 'செ', 'பு', 'வி', 'வெ', 'ச'];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _api = ApiService();

  DateTime month = DateTime.now();
  DateTime selected = DateTime.now();

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> calendarDays = [];

  static const Map<int, String> tamilGregorianMonths = {
    1: 'ஜனவரி',
    2: 'பிப்ரவரி',
    3: 'மார்ச்',
    4: 'ஏப்ரல்',
    5: 'மே',
    6: 'ஜூன்',
    7: 'ஜூலை',
    8: 'ஆகஸ்ட்',
    9: 'செப்டம்பர்',
    10: 'அக்டோபர்',
    11: 'நவம்பர்',
    12: 'டிசம்பர்',
  };

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _api.getCalendarMonth(
        year: month.year,
        month: month.month,
      );

      // API response format:
      // { "ok": true, "data": { "days": [...] } }
      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid calendar response.');
      }

      final days = data['days'];

      if (days is! List) {
        throw Exception('Calendar days were not found.');
      }

      final parsedDays = days
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        calendarDays = parsedDays;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        calendarDays = [];
        isLoading = false;
        errorMessage = 'நாள்காட்டியைப் பெற முடியவில்லை.\n$e';
      });
    }
  }

  Map<String, dynamic>? get selectedDayData {
    for (final day in calendarDays) {
      if (day['gregorian_date'] == _dateString(selected)) {
        return day;
      }
    }

    return null;
  }

  String _dateString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  void _changeMonth(int difference) {
    final newMonth = DateTime(
      month.year,
      month.month + difference,
      1,
    );

    setState(() {
      month = newMonth;

      // Keep the selected day within the new month.
      final lastDay = DateTime(
        newMonth.year,
        newMonth.month + 1,
        0,
      ).day;

      selected = DateTime(
        newMonth.year,
        newMonth.month,
        selected.day > lastDay ? lastDay : selected.day,
      );
    });

    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final totalDays = DateTime(month.year, month.month + 1, 0).day;

    // Sunday-first calendar.
    final offset = firstDay.weekday % 7;
    final cells = ((offset + totalDays + 6) ~/ 7) * 7;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'மாத நாள்காட்டி',
                  style: TextStyle(
                    color: Color(0xFFF7F2FF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${tamilGregorianMonths[month.month]} • ${month.year}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFFB89AFF),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: weekdays
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  color: lavender,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(35),
                      child: CircularProgressIndicator(),
                    )
                  else if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 35,
                            color: softGold,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _loadMonth,
                            child: const Text('மீண்டும் முயற்சி செய்'),
                          ),
                        ],
                      ),
                    )
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: GridView.builder(
                        key: ValueKey('${month.year}-${month.month}'),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cells,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemBuilder: (context, index) {
                          final dayNumber = index - offset + 1;

                          if (dayNumber < 1 ||
                              dayNumber > totalDays) {
                            return const SizedBox.shrink();
                          }

                          final date = DateTime(
                            month.year,
                            month.month,
                            dayNumber,
                          );

                          final dateData = calendarDays.cast<
                              Map<String, dynamic>?>().firstWhere(
                            (item) =>
                                item?['gregorian_date'] ==
                                _dateString(date),
                            orElse: () => null,
                          );

                          final tamilDay = dateData?['day'];

                          final isSelected =
                              date.year == selected.year &&
                              date.month == selected.month &&
                              date.day == selected.day;

                          final now = DateTime.now();

                          final isToday =
                              date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day;

                          return InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: () {
                              setState(() {
                                selected = date;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? royalPurple
                                    : isToday
                                        ? royalPurple.withValues(alpha: 0.28)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: isSelected
                                      ? softGold
                                      : isToday
                                          ? lavender
                                          : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$dayNumber',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : cream,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (tamilDay != null)
                                    FittedBox(
                                      child: Text(
                                        '$tamilDay',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? softGold
                                              : cream.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 13),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Builder(
              builder: (context) {
                final data = selectedDayData;

                return ListTile(
                  leading: const Icon(
                    Icons.event,
                    color: softGold,
                  ),
                  title: Text(_dateString(selected)),
                  subtitle: data == null
                      ? const Text(
                          'இந்த நாளுக்கான தமிழ் தேதி கிடைக்கவில்லை.',
                        )
                      : Text(
                          'தமிழ் தேதி: ${data['day']} '
                          '${data['month_name_tamil'] ?? ''}\n'
                          'தமிழ் ஆண்டு: '
                          '${data['year_name_tamil'] ?? '—'}\n'
                          'கிழமை: '
                          '${data['weekday_name_tamil'] ?? '—'}',
                        ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: () {
              final today = DateTime.now();

              setState(() {
                month = DateTime(today.year, today.month, 1);
                selected = today;
              });

              _loadMonth();
            },
            icon: const Icon(Icons.today),
            label: const Text('இன்றைக்குத் திரும்பு'),
          ),
        ],
      ),
    );
  }
}