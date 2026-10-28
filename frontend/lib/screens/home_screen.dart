import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/theme.dart';
import '../services/api_service.dart';
import 'calendar_screen.dart';
import 'panchangam_screen.dart';
import 'festivals_screen.dart';
import 'rasi_palan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onNavigate,
  });

  /// MainNavigation supplies this callback to switch existing tabs.
  final ValueChanged<int>? onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();

  Map<String, dynamic>? day;
  Map<String, dynamic>? panchangam;

  bool loading = true;
  String? errorMessage;

  String selectedLocation = 'Chennai';

  static const String _locationPreferenceKey = 'selected_tamil_nadu_city';

  static const Map<String, String> tamilNaduCities = {
    'Chennai': 'சென்னை',
    'Coimbatore': 'கோயம்புத்தூர்',
    'Madurai': 'மதுரை',
    'Tiruchirappalli': 'திருச்சிராப்பள்ளி',
    'Salem': 'சேலம்',
    'Tirunelveli': 'திருநெல்வேலி',
    'Erode': 'ஈரோடு',
    'Vellore': 'வேலூர்',
    'Thanjavur': 'தஞ்சாவூர்',
    'Dindigul': 'திண்டுக்கல்',
    'Thoothukudi': 'தூத்துக்குடி',
    'Nagercoil': 'நாகர்கோவில்',
    'Tiruppur': 'திருப்பூர்',
    'Karur': 'கரூர்',
    'Kanchipuram': 'காஞ்சிபுரம்',
    'Cuddalore': 'கடலூர்',
    'Villupuram': 'விழுப்புரம்',
    'Nagapattinam': 'நாகப்பட்டினம்',
    'Namakkal': 'நாமக்கல்',
    'Krishnagiri': 'கிருஷ்ணகிரி',
    'Sivakasi': 'சிவகாசி',
    'Ramanathapuram': 'இராமநாதபுரம்',
    'Tiruvannamalai': 'திருவண்ணாமலை',
    'Perambalur': 'பெரம்பலூர்',
    'Ariyalur': 'அரியலூர்',
    'Pudukkottai': 'புதுக்கோட்டை',
    'Sivaganga': 'சிவகங்கை',
    'Virudhunagar': 'விருதுநகர்',
    'Dharmapuri': 'தருமபுரி',
    'Theni': 'தேனி',
    'Tenkasi': 'தென்காசி',
    'Tirupattur': 'திருப்பத்தூர்',
    'Ranipet': 'ராணிப்பேட்டை',
    'Kallakurichi': 'கள்ளக்குறிச்சி',
    'Mayiladuthurai': 'மயிலாடுதுறை',
    'Tiruvallur': 'திருவள்ளூர்',
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  String get _apiLocation => selectedLocation.toLowerCase();

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedLocation =
          prefs.getString(_locationPreferenceKey) ?? 'Chennai';

      if (!mounted) return;

      setState(() {
        selectedLocation = tamilNaduCities.containsKey(savedLocation)
            ? savedLocation
            : 'Chennai';
      });

      await _load();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'செயலியைத் தொடங்க முடியவில்லை.';
      });
    }
  }

  Future<void> _load() async {
  if (!mounted) return;

  setState(() {
    loading = true;
    errorMessage = null;
  });

  try {
    final today = DateTime.now();

    final results = await Future.wait([
      api.getCalendarDay(today, location: _apiLocation),
      api.getPanchangam(today, location: _apiLocation),
    ]);

    final calendarResult = results[0];
    final panchangamResult = results[1];

    if (calendarResult['ok'] == false) {
      throw Exception(
        calendarResult['error'] ??
            calendarResult['message'] ??
            'Calendar API request failed',
      );
    }

    final calendarData = calendarResult['data'];
    final panchangamData = panchangamResult['data'];

    if (calendarData is! Map) {
      throw const FormatException(
        'Calendar information is missing.',
      );
    }

    if (!mounted) return;

    setState(() {
      day = Map<String, dynamic>.from(calendarData);

      panchangam = panchangamData is Map
          ? Map<String, dynamic>.from(panchangamData)
          : null;

      errorMessage = null;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      errorMessage = _friendlyError(error);
    });
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}

  String _friendlyError(Object error) {
    final message = error.toString();

    if (message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Failed host lookup')) {
      return 'சேவையகத்துடன் இணைக்க முடியவில்லை.\n'
          'Backend இயங்குகிறதா எனச் சரிபார்க்கவும்.';
    }

    if (message.contains('TimeoutException')) {
      return 'சேவையகத்திலிருந்து பதில் வரவில்லை.\n'
          'மீண்டும் முயற்சிக்கவும்.';
    }

    return 'தமிழ் நாள்காட்டி தரவைப் பெற முடியவில்லை.\n'
        'மீண்டும் முயற்சிக்கவும்.';
  }

  Future<void> _chooseLocation() async {
    final location = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF211333),
          title: const Text(
            'இடத்தைத் தேர்ந்தெடுக்கவும்',
            style: TextStyle(
              color: softGold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                'தமிழ்நாட்டிலுள்ள நகரங்கள்',
                style: TextStyle(color: lavender),
              ),
            ),
            ...tamilNaduCities.entries.map((entry) {
              final isSelected = entry.key == selectedLocation;

              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(dialogContext, entry.key);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${entry.value} (${entry.key})',
                        style: TextStyle(
                          color: isSelected ? softGold : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: softGold,
                      ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );

    if (location == null || !mounted) return;

    setState(() {
      selectedLocation = location;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _locationPreferenceKey,
        location,
      );

      await _load();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'இடத்தைச் சேமிக்க முடியவில்லை.';
      });
    }
  }

  String _englishDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _displayValue(dynamic value) {
    if (value == null) return '—';

    final text = value.toString().trim();

    if (text.isEmpty || text == '--:--') return '—';

    return text;
  }

  String _sunriseValue() {
    return _displayValue(
      day?['sunrise'] ?? day?['sunrise_time'] ?? day?['sunriseTime'],
    );
  }

  String _sunsetValue() {
    return _displayValue(
      day?['sunset'] ?? day?['sunset_time'] ?? day?['sunsetTime'],
    );
  }

  // Opens a standalone screen only when HomeScreen is used
  // without MainNavigation's callback.
  void _navigate(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => screen,
      ),
    );
  }

  // Calendar: select the existing Calendar tab.
  void _openCalendar() {
    final navigate = widget.onNavigate;

    if (navigate != null) {
      navigate(1);
      return;
    }

    _navigate(const CalendarScreen());
  }

  // Panchangam: select the existing Panchangam tab.
  void _openPanchangam() {
    final navigate = widget.onNavigate;

    if (navigate != null) {
      navigate(2);
      return;
    }

    _navigate(const PanchangamScreen());
  }

  // Festivals: select the existing Festivals tab.
  void _openFestivals() {
    final navigate = widget.onNavigate;

    if (navigate != null) {
      navigate(3);
      return;
    }

    _navigate(const FestivalsScreen());
  }

  void _openHoroscope() {
    _navigate(const RasiPalanScreen());
  }

  void _openGoodTime() {
    // Good-time information belongs to Panchangam.
    _openPanchangam();
  }

  void _openReminders() {
    _showFeatureMessage(
      'நினைவூட்டல்கள்',
      'நினைவூட்டல்களை உருவாக்கவும் சேமிக்கவும் '
          'அறிவிப்புகளைப் பெறவும் தனியான reminder '
          'அம்சம் தேவை.',
    );
  }

  void _showNavigationOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF211333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: lavender.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'மாத நாள்காட்டி',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openCalendar();
                  },
                ),
                _MenuItem(
                  icon: Icons.temple_hindu_rounded,
                  title: 'பஞ்சாங்கம்',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openPanchangam();
                  },
                ),
                _MenuItem(
                  icon: Icons.celebration_rounded,
                  title: 'விழாக்கள்',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openFestivals();
                  },
                ),
                _MenuItem(
                  icon: Icons.auto_awesome_rounded,
                  title: 'ராசிபலன்',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openHoroscope();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeatureMessage(
    String title,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF211333),
          title: Text(
            title,
            style: const TextStyle(
              color: softGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'சரி',
                style: TextStyle(color: softGold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final tamilDay = day?['day'];
    final tamilMonth = day?['month_name_tamil'];
    final weekday = day?['weekday_name_tamil'];

    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: softGold,
          backgroundColor: const Color(0xFF211333),
          child: LayoutBuilder(
            builder: (context, viewport) {
              final isWide = viewport.maxWidth >= 900;

              final horizontalPadding = isWide ? 28.0 : 16.0;

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  24,
                ),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showNavigationOptions,
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'தமிழ் நாள்காட்டி',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: softGold,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'நம் மரபும், நம் காலமும், நம் நாளும்',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: lavender,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _openReminders,
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: softGold,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton.icon(
                      onPressed: _chooseLocation,
                      icon: const Icon(
                        Icons.location_on_rounded,
                        color: softGold,
                        size: 17,
                      ),
                      label: Text(
                        '${tamilNaduCities[selectedLocation]}, தமிழ்நாடு',
                        style: const TextStyle(
                          color: lavender,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                      ),
                      child: _buildCalendarCard(
                        today: today,
                        tamilDay: tamilDay,
                        tamilMonth: tamilMonth,
                        weekday: weekday,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSpecialDayCard(),
                  const SizedBox(height: 18),
                  const Text(
                    'விரைவு அணுகல்',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      final columns = width >= 1200 ? 6 : 3;

                      final ratio = width >= 800 ? 1.15 : 0.90;

                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 9,
                        crossAxisSpacing: 9,
                        childAspectRatio: ratio,
                        children: [
                          _QuickCard(
                            icon: Icons.calendar_month_rounded,
                            title: 'மாத நாள்காட்டி',
                            subtitle: 'மாத தேதிகள்',
                            onTap: _openCalendar,
                          ),
                          _QuickCard(
                            icon: Icons.temple_hindu_rounded,
                            title: 'பஞ்சாங்கம்',
                            subtitle: 'நேர விவரங்கள்',
                            onTap: _openPanchangam,
                          ),
                          _QuickCard(
                            icon: Icons.celebration_rounded,
                            title: 'விழாக்கள்',
                            subtitle: 'முக்கிய நாட்கள்',
                            onTap: _openFestivals,
                          ),
                          _QuickCard(
                            icon: Icons.access_time_rounded,
                            title: 'நல்ல நேரம்',
                            subtitle: 'நேர விவரங்கள்',
                            onTap: _openGoodTime,
                          ),
                          _QuickCard(
                            icon: Icons.auto_awesome_rounded,
                            title: 'ராசிபலன்',
                            subtitle: 'ராசி விவரங்கள்',
                            onTap: _openHoroscope,
                          ),
                          _QuickCard(
                            icon: Icons.notifications_active_rounded,
                            title: 'நினைவூட்டல்',
                            subtitle: 'நினைவூட்டல்கள்',
                            onTap: _openReminders,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard({
    required DateTime today,
    required dynamic tamilDay,
    required dynamic tamilMonth,
    required dynamic weekday,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF321653),
            Color(0xFF1B0D30),
            Color(0xFF10091D),
          ],
        ),
        border: Border.all(
          color: softGold.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: royalPurple.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'இன்றைய தேதி',
            style: TextStyle(
              color: lavender,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          if (loading && day == null)
            const Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(
                color: softGold,
              ),
            )
          else if (errorMessage != null && day == null)
            Column(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: softGold,
                  size: 34,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: softGold,
                    height: 1.5,
                  ),
                ),
                TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'மீண்டும் முயற்சி செய்',
                  ),
                ),
              ],
            )
          else ...[
            Text(
              '$tamilDay $tamilMonth',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: softGold,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            if (weekday != null)
              Text(
                weekday.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 5),
            Text(
              _englishDate(today),
              style: const TextStyle(
                color: cream,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 11,
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SunTimeCard(
                    icon: Icons.wb_sunny_rounded,
                    title: 'சூரிய உதயம்',
                    time: _sunriseValue(),
                  ),
                ),
                Expanded(
                  child: _SunTimeCard(
                    icon: Icons.wb_twilight_rounded,
                    title: 'சூரிய அஸ்தமனம்',
                    time: _sunsetValue(),
                  ),
                ),
              ],
            ),
          ),
          if (loading && day != null) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              color: softGold,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialDayCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openFestivals,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF211333),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: softGold.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF39234E),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: softGold,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'இன்றைய சிறப்பு',
                      style: TextStyle(
                        color: lavender,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'இன்றைய நாள்',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'விழாக்கள் மற்றும் சிறப்பு நாட்களைப் பார்க்க',
                      style: TextStyle(
                        color: lavender,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: softGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunTimeCard extends StatelessWidget {
  const _SunTimeCard({
    required this.icon,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: softGold,
          size: 26,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: lavender,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: softGold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF382052),
                Color(0xFF21112F),
              ],
            ),
            border: Border.all(
              color: softGold.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: softGold,
                size: 27,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: lavender,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: softGold,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: softGold,
      ),
      onTap: onTap,
    );
  }
}
