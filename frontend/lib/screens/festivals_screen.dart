
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../services/api_service.dart';

class FestivalsScreen extends StatefulWidget {
  const FestivalsScreen({super.key});

  @override
  State<FestivalsScreen> createState() => _FestivalsScreenState();
}

class _FestivalsScreenState extends State<FestivalsScreen> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _festivals = [];

  bool _loading = true;
  String? _errorMessage;

  int _selectedYear = DateTime.now().year;
  String _selectedFilter = 'அனைத்தும்';

  static const List<String> _filters = [
    'அனைத்தும்',
    'முக்கியம்',
    'விரதம்',
  ];

  static const Map<String, String> _tamilNames = {
    'pongal': 'பொங்கல்',
    'makar-sankranti': 'பொங்கல்',
    'makar sankranti': 'பொங்கல்',
    'tamil-new-year': 'தமிழ் புத்தாண்டு',
    'tamil new year': 'தமிழ் புத்தாண்டு',
    'puthandu': 'தமிழ் புத்தாண்டு',
    'thai-poosam': 'தைப்பூசம்',
    'thaipusam': 'தைப்பூசம்',
    'thai poosam': 'தைப்பூசம்',
    'vinayagar-chaturthi': 'விநாயகர் சதுர்த்தி',
    'vinayagar chaturthi': 'விநாயகர் சதுர்த்தி',
    'ganesh-chaturthi': 'விநாயகர் சதுர்த்தி',
    'ganesh chaturthi': 'விநாயகர் சதுர்த்தி',
    'navaratri': 'நவராத்திரி',
    'navratri': 'நவராத்திரி',
    'diwali': 'தீபாவளி',
    'deepavali': 'தீபாவளி',
    'karthigai-deepam': 'கார்த்திகை தீபம்',
    'karthigai deepam': 'கார்த்திகை தீபம்',
    'karthikai-deepam': 'கார்த்திகை தீபம்',
    'maha-shivaratri': 'மகா சிவராத்திரி',
    'maha shivaratri': 'மகா சிவராத்திரி',
    'shivarathri': 'மகா சிவராத்திரி',
    'ayudha-pooja': 'ஆயுத பூஜை',
    'ayudha pooja': 'ஆயுத பூஜை',
    'saraswati-puja': 'சரஸ்வதி பூஜை',
    'saraswati puja': 'சரஸ்வதி பூஜை',
    'vijayadashami': 'விஜயதசமி',
    'panguni-uthiram': 'பங்குனி உத்திரம்',
    'panguni uthiram': 'பங்குனி உத்திரம்',
    'chitra-pournami': 'சித்திரை பௌர்ணமி',
    'aadi-perukku': 'ஆடிப்பெருக்கு',
    'aadi-amavasai': 'ஆடி அமாவாசை',
    'krishna-janmashtami': 'கிருஷ்ண ஜெயந்தி',
    'janmashtami': 'கிருஷ்ண ஜெயந்தி',
    'ram-navami': 'ராம நவமி',
    'bhai-dooj': 'பாய் தூஜ்',
    'chhath': 'சத் பூஜை',
    'dhanteras': 'தன்தேரஸ்',
  };

  static const Map<String, String> _descriptions = {
    'pongal': 'தமிழர் அறுவடைத் திருநாள்',
    'makar-sankranti': 'அறுவடை மற்றும் சூரிய வழிபாட்டுத் திருநாள்',
    'tamil-new-year': 'தமிழ்ப் புத்தாண்டின் தொடக்கம்',
    'puthandu': 'தமிழ்ப் புத்தாண்டின் தொடக்கம்',
    'thai-poosam': 'முருகப்பெருமானுக்கு உகந்த திருநாள்',
    'thaipusam': 'முருகப்பெருமானுக்கு உகந்த திருநாள்',
    'vinayagar-chaturthi': 'விநாயகர் வழிபாட்டுத் திருநாள்',
    'ganesh-chaturthi': 'விநாயகர் வழிபாட்டுத் திருநாள்',
    'navaratri': 'அம்பிகை வழிபாட்டிற்குரிய ஒன்பது நாள் விழா',
    'navratri': 'அம்பிகை வழிபாட்டிற்குரிய ஒன்பது நாள் விழா',
    'diwali': 'தீபாவளி ஒளித் திருநாள்',
    'deepavali': 'தீபாவளி ஒளித் திருநாள்',
    'karthigai-deepam': 'விளக்கேற்றி வழிபடும் திருநாள்',
    'ayudha-pooja': 'கருவிகள் மற்றும் தொழிலுக்கான வழிபாட்டு நாள்',
    'saraswati-puja': 'கல்வி மற்றும் கலைகளுக்கான வழிபாட்டு நாள்',
    'vijayadashami': 'நல்ல தொடக்கங்களுடன் தொடர்புடைய திருநாள்',
    'maha-shivaratri': 'சிவபெருமானுக்குரிய வழிபாட்டு இரவு',
    'panguni-uthiram': 'முருக வழிபாட்டுடன் தொடர்புடைய திருநாள்',
  };

  @override
  void initState() {
    super.initState();
    _loadFestivals();
  }

  // ------------------------------------------------------------
  // LOAD REAL FESTIVAL DATA
  // ------------------------------------------------------------

  Future<void> _loadFestivals() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.getFestivalsForYear(
        _selectedYear,
      );

      final rawData = response['data'];
      final festivals = _extractFestivalList(rawData);

      if (!mounted) return;

      setState(() {
        _festivals = festivals;
        _loading = false;

        if (festivals.isEmpty) {
          _errorMessage =
              'இந்த ஆண்டிற்கான விழா விவரங்கள் கிடைக்கவில்லை.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _festivals = [];
        _loading = false;
        _errorMessage =
            'விழா விவரங்களைப் பெற முடியவில்லை.\n'
            'Backend மற்றும் Festival API-ஐச் சரிபார்க்கவும்.';
      });

      debugPrint('Festival loading error: $error');
    }
  }

  // API response structure:
  // {
  //   "ok": true,
  //   "data": {
  //     "festivals": {
  //       "diwali": {
  //         "en": "Diwali",
  //         "dates": ["2026-11-08"]
  //       }
  //     }
  //   }
  // }

  List<Map<String, dynamic>> _extractFestivalList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (value is! Map) {
      return [];
    }

    final data = Map<String, dynamic>.from(value);

    final festivalMap = data['festivals'];

    if (festivalMap is Map) {
      final List<Map<String, dynamic>> result = [];

      festivalMap.forEach((key, item) {
        if (item is Map) {
          final festival = Map<String, dynamic>.from(item);

          festival['id'] ??= key.toString();

          result.add(festival);
        }
      });

      return result;
    }

    for (final key in ['data', 'results', 'items', 'events']) {
      final nested = data[key];

      if (nested is List) {
        return nested
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (nested is Map) {
        final result = _extractFestivalList(nested);

        if (result.isNotEmpty) {
          return result;
        }
      }
    }

    return [];
  }

  // ------------------------------------------------------------
  // FESTIVAL NAME AND DESCRIPTION
  // ------------------------------------------------------------

  String _rawFestivalName(Map<String, dynamic> festival) {
    return (
      festival['name_tamil'] ??
      festival['name_local'] ??
      festival['name'] ??
      festival['festival_name'] ??
      festival['title'] ??
      festival['en'] ??
      festival['id'] ??
      ''
    ).toString().trim();
  }

  String _festivalName(Map<String, dynamic> festival) {
    final rawName = _rawFestivalName(festival);

    if (rawName.isEmpty) {
      return 'பெயர் கிடைக்கவில்லை';
    }

    final key = rawName.toLowerCase().trim();

    return _tamilNames[key] ?? rawName;
  }

  String _festivalDescription(Map<String, dynamic> festival) {
    final description = (
      festival['description_tamil'] ??
      festival['description_local'] ??
      festival['description']
    )?.toString().trim();

    if (description != null && description.isNotEmpty) {
      return description;
    }

    final rawName = _rawFestivalName(festival).toLowerCase().trim();

    return _descriptions[rawName] ?? 'விழா விவரங்கள்';
  }

  // ------------------------------------------------------------
  // FESTIVAL DATE
  // ------------------------------------------------------------

  String? _selectedDateString(Map<String, dynamic> festival) {
    final dynamic rawDates =
        festival['published_dates'] ?? festival['dates'];

    if (rawDates is List && rawDates.isNotEmpty) {
      final dates = rawDates
          .map((item) => item.toString())
          .toList();

      // Prefer the date for the selected year.
      for (final value in dates) {
        if (value.startsWith('$_selectedYear-')) {
          return value;
        }
      }

      // No matching year: don't show another year's date.
      return null;
    }

    final value = (
      festival['date'] ??
      festival['festival_date'] ??
      festival['observance_date'] ??
      festival['gregorian_date']
    )?.toString();

    if (value == null || value.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value);

    if (parsed != null && parsed.year != _selectedYear) {
      return null;
    }

    return value;
  }

  DateTime? _dateFor(Map<String, dynamic> festival) {
    final value = _selectedDateString(festival);

    if (value == null) return null;

    return DateTime.tryParse(value);
  }

  String _formatDate(Map<String, dynamic> festival) {
    final value = _selectedDateString(festival);

    if (value == null) {
      return 'இந்த ஆண்டின் தேதி கிடைக்கவில்லை';
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) return value;

    const months = [
      'ஜனவரி',
      'பிப்ரவரி',
      'மார்ச்',
      'ஏப்ரல்',
      'மே',
      'ஜூன்',
      'ஜூலை',
      'ஆகஸ்ட்',
      'செப்டம்பர்',
      'அக்டோபர்',
      'நவம்பர்',
      'டிசம்பர்',
    ];

    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  // ------------------------------------------------------------
  // FILTERS
  // ------------------------------------------------------------

  String _category(Map<String, dynamic> festival) {
    return (
      festival['category'] ??
      festival['type'] ??
      festival['kind'] ??
      ''
    ).toString().toLowerCase();
  }

  bool _isVrat(Map<String, dynamic> festival) {
    final category = _category(festival);
    final name = _festivalName(festival);

    return category.contains('vrat') ||
        category.contains('fast') ||
        name.contains('ஏகாதசி') ||
        name.contains('அமாவாசை') ||
        name.contains('பௌர்ணமி') ||
        name.contains('சிவராத்திரி');
  }

  bool _isImportant(Map<String, dynamic> festival) {
    final category = _category(festival);

    return category.contains('major') ||
        category.contains('important') ||
        category.contains('holiday');
  }

  List<Map<String, dynamic>> get _filteredFestivals {
    final result = _festivals.where((festival) {
      if (_selectedFilter == 'விரதம்') {
        return _isVrat(festival);
      }

      if (_selectedFilter == 'முக்கியம்') {
        return _isImportant(festival);
      }

      return true;
    }).toList();

    result.sort((a, b) {
      final dateA = _dateFor(a);
      final dateB = _dateFor(b);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateA.compareTo(dateB);
    });

    return result;
  }

  // ------------------------------------------------------------
  // IMAGES
  // ------------------------------------------------------------

  String _imageAsset(Map<String, dynamic> festival) {
    final name = (
      festival['id'] ??
      festival['en'] ??
      festival['name'] ??
      festival['title'] ??
      ''
    ).toString().toLowerCase();

    if (name.contains('pongal') || name.contains('sankranti')) {
      return 'assets/festivals/pongal.jpg';
    }

    if (name.contains('new-year') ||
        name.contains('new year') ||
        name.contains('puthandu')) {
      return 'assets/festivals/tamil_new_year.jpg';
    }

    if (name.contains('thaipusam') ||
        name.contains('thai-poosam') ||
        name.contains('thai poosam')) {
      return 'assets/festivals/thaipusam.jpg';
    }

    if (name.contains('vinayagar') ||
        name.contains('ganesh') ||
        name.contains('vinayaka')) {
      return 'assets/festivals/vinayagar_chaturthi.jpg';
    }

    if (name.contains('navaratri') || name.contains('navratri')) {
      return 'assets/festivals/navaratri.jpg';
    }

    if (name.contains('diwali') || name.contains('deepavali')) {
      return 'assets/festivals/deepavali.jpg';
    }

    if (name.contains('karthigai') || name.contains('karthikai')) {
      return 'assets/festivals/karthigai_deepam.jpg';
    }

    if (name.contains('shivaratri') || name.contains('shivarathri')) {
      return 'assets/festivals/maha_shivaratri.jpg';
    }

    return 'assets/festivals/default_festival.jpg';
  }

  IconData _fallbackIcon(Map<String, dynamic> festival) {
    final name = _festivalName(festival).toLowerCase();

    if (name.contains('பொங்கல்')) {
      return Icons.agriculture_rounded;
    }

    if (name.contains('முருக') || name.contains('தைப்பூசம்')) {
      return Icons.temple_hindu_rounded;
    }

    if (name.contains('விநாயகர்')) {
      return Icons.celebration_rounded;
    }

    if (name.contains('தீபாவளி') || name.contains('தீபம்')) {
      return Icons.light_mode_rounded;
    }

    if (name.contains('புத்தாண்டு')) {
      return Icons.wb_sunny_rounded;
    }

    return Icons.event_rounded;
  }

  Widget _festivalImage(
    Map<String, dynamic> festival, {
    double width = 76,
    double height = 82,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        _imageAsset(festival),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [deepPurple, royalPurple],
              ),
            ),
            child: Icon(
              _fallbackIcon(festival),
              color: softGold,
              size: 35,
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // YEAR SELECTION
  // ------------------------------------------------------------

  Future<void> _changeYear(int? year) async {
    if (year == null || year == _selectedYear) return;

    setState(() {
      _selectedYear = year;
    });

    await _loadFestivals();
  }

  // ------------------------------------------------------------
  // FESTIVAL DETAILS
  // ------------------------------------------------------------

  void _showFestivalDetails(Map<String, dynamic> festival) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF211333),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lavender.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: _festivalImage(
                    festival,
                    width: double.infinity,
                    height: 190,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _festivalName(festival),
                  style: const TextStyle(
                    color: softGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: softGold,
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _formatDate(festival),
                        style: const TextStyle(
                          color: lavender,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _festivalDescription(festival),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text(
                      'மூடு',
                      style: TextStyle(color: softGold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD SCREEN
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final festivals = _filteredFestivals;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadFestivals,
        color: softGold,
        backgroundColor: const Color(0xFF211333),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            const Text(
              'விழாக்கள்',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'தமிழர் திருநாட்கள் மற்றும் விழா விவரங்கள்',
              style: TextStyle(
                color: lavender,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Year selector
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF211333),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: softGold.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: softGold,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'ஆண்டு தேர்வு',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DropdownButton<int>(
                    value: _selectedYear,
                    dropdownColor: const Color(0xFF211333),
                    underline: const SizedBox.shrink(),
                    iconEnabledColor: softGold,
                    style: const TextStyle(
                      color: softGold,
                      fontWeight: FontWeight.bold,
                    ),
                    items: List.generate(
                      11,
                      (index) => DateTime.now().year - 5 + index,
                    ).map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: _changeYear,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final selected = filter == _selectedFilter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: softGold,
                      backgroundColor: const Color(0xFF211333),
                      labelStyle: TextStyle(
                        color: selected
                            ? const Color(0xFF211333)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: softGold.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(
                    color: softGold,
                  ),
                ),
              )
            else if (_errorMessage != null)
              _buildMessage(
                icon: Icons.event_busy_rounded,
                message: _errorMessage!,
                showRetry: true,
              )
            else if (festivals.isEmpty)
              _buildMessage(
                icon: Icons.event_note_rounded,
                message: 'இந்தப் பிரிவில் விழாக்கள் இல்லை.',
              )
            else ...[
              Text(
                '${festivals.length} விழாக்கள் • $_selectedYear',
                style: const TextStyle(
                  color: lavender,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              ...festivals.map(_buildFestivalCard),
              const SizedBox(height: 12),
              const Text(
                'விழா தேதிகள் இணைக்கப்பட்ட API-யிலிருந்து பெறப்படுகின்றன.',
                style: TextStyle(
                  color: lavender,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY / ERROR MESSAGE
  // ------------------------------------------------------------

  Widget _buildMessage({
    required IconData icon,
    required String message,
    bool showRetry = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF211333),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: softGold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: softGold,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: lavender,
              height: 1.5,
            ),
          ),
          if (showRetry) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadFestivals,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('மீண்டும் முயற்சி செய்'),
              style: OutlinedButton.styleFrom(
                foregroundColor: softGold,
                side: BorderSide(
                  color: softGold.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FESTIVAL CARD
  // ------------------------------------------------------------

  Widget _buildFestivalCard(Map<String, dynamic> festival) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFestivalDetails(festival),
          borderRadius: BorderRadius.circular(17),
          child: Ink(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF211333),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: softGold.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                _festivalImage(festival),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _festivalName(festival),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatDate(festival),
                        style: const TextStyle(
                          color: lavender,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _festivalDescription(festival),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: lavender,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: softGold,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
