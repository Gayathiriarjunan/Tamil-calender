import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../services/api_service.dart';

class PanchangamScreen extends StatefulWidget {
  const PanchangamScreen({super.key});

  @override
  State<PanchangamScreen> createState() => _PanchangamScreenState();
}

class _PanchangamScreenState extends State<PanchangamScreen> {
  final ApiService _api = ApiService();

  late DateTime _selectedDate;
  Map<String, dynamic>? _day;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadPanchangam();
  }

  Future<void> _loadPanchangam() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _api.getPanchangam(_selectedDate);
      final data = response['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('சரியான பஞ்சாங்கத் தரவு கிடைக்கவில்லை.');
      }

      if (!mounted) return;

      setState(() {
        _day = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _value(String key) {
    final value = _day?[key];

    if (value == null || value.toString().isEmpty) {
      return 'தரவு கிடைக்கவில்லை';
    }

    return value.toString();
  }

  String _minutesToTime(String key) {
    final value = _day?[key];

    if (value is! num) {
      return 'தரவு கிடைக்கவில்லை';
    }

    final minutes = value.toInt();

    if (minutes < 0) {
      return 'தரவு கிடைக்கவில்லை';
    }

    final hour = (minutes ~/ 60) % 24;
    final minute = minutes % 60;
    final period = hour >= 12 ? 'மாலை' : 'காலை';

    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$period ${displayHour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  String _formatSelectedDate() {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');
    return '$day-$month-${_selectedDate.year}';
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: softGold,
              onPrimary: ink,
              surface: deepPurple,
              onSurface: cream,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDate = picked;
    });

    await _loadPanchangam();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'திதி',
        _value('tithi_name'),
        Icons.brightness_2_rounded,
      ),
      (
        'நட்சத்திரம்',
        _value('nakshatra_name'),
        Icons.star_rounded,
      ),
      (
        'யோகம்',
        _value('yoga_name'),
        Icons.auto_awesome_rounded,
      ),
      (
        'கரணம்',
        _value('karana_name'),
        Icons.auto_awesome_rounded,
      ),
      (
        'சூரிய உதயம்',
        _minutesToTime('sunrise'),
        Icons.wb_twilight_rounded,
      ),
      (
        'சூரிய மறைவு',
        _minutesToTime('sunset'),
        Icons.wb_twilight_rounded,
      ),
      (
        'ராகு காலம் தொடக்கம்',
        _minutesToTime('rahu_kalam'),
        Icons.schedule_rounded,
      ),
      (
        'எமகண்டம் தொடக்கம்',
        _minutesToTime('yamagandam'),
        Icons.access_time_rounded,
      ),
      (
        'குளிகை தொடக்கம்',
        _minutesToTime('gulikai'),
        Icons.access_time_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text('பஞ்சாங்கம்'),
        actions: [
          IconButton(
            tooltip: 'தேதியைத் தேர்ந்தெடுக்கவும்',
            onPressed: _chooseDate,
            icon: const Icon(Icons.calendar_month_rounded),
          ),
          IconButton(
            tooltip: 'மீண்டும் ஏற்றவும்',
            onPressed: _loadPanchangam,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'இன்றைய பஞ்சாங்கம்',
              style: TextStyle(
                color: softGold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'தேதி: ${_formatSelectedDate()}',
              style: const TextStyle(
                color: lavender,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _chooseDate,
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('வேறு தேதியைத் தேர்ந்தெடுக்கவும்'),
              style: OutlinedButton.styleFrom(
                foregroundColor: softGold,
                side: const BorderSide(color: softGold),
              ),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    color: softGold,
                  ),
                ),
              ),

            if (!_loading && _error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'பஞ்சாங்கத் தரவைப் பெற முடியவில்லை',
                        style: TextStyle(
                          color: softGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(color: cream),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _loadPanchangam,
                        icon: const Icon(Icons.refresh),
                        label: const Text('மீண்டும் முயற்சிக்கவும்'),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_loading && _day != null)
              ...items.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      leading: Icon(
                        item.$3,
                        color: softGold,
                        size: 23,
                      ),
                      title: Text(
                        item.$1,
                        style: const TextStyle(
                          color: cream,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.$2,
                          style: const TextStyle(
                            color: lavender,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      iconColor: softGold,
                      collapsedIconColor: lavender,
                      childrenPadding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 16,
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${item.$1}: ${item.$2}',
                            style: const TextStyle(
                              color: cream,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 8),
            const Text(
              'குறிப்பு: காட்டப்படும் தரவு Shastra Panchangam API-யிலிருந்து '
              'பெறப்படுகிறது. நேரங்கள் சென்னை இடத்திற்கானவை. '
              'இந்த API Drik கணக்கீட்டு முறையைப் பயன்படுத்துகிறது; '
              'பாரம்பரிய வாக்கிய பஞ்சாங்கத்துடன் வேறுபாடுகள் இருக்கலாம்.',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
