import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/panchangam_screen.dart';
import 'screens/festivals_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TamilNallkaatiApp());
}

class TamilNallkaatiApp extends StatelessWidget {
  const TamilNallkaatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'தமிழ் நாள்காட்டி',
      debugShowCheckedModeBanner: false,
      theme: buildTamilTheme(),
      home: const AppStartScreen(),
    );
  }
}

// Always displays the Welcome Page when the app starts.
class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool hasStarted = false;

  void _completeWelcome() {
    if (!mounted) return;

    setState(() {
      hasStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasStarted) {
      return const MainNavigation();
    }

    return WelcomeScreen(
      onGetStarted: _completeWelcome,
    );
  }
}

// Main application navigation.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selected = 0;

  void _selectTab(int index) {
    if (index < 0 || index > 4) return;

    setState(() {
      selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onNavigate: _selectTab,
      ),
      const CalendarScreen(),
      const PanchangamScreen(),
      const FestivalsScreen(),
      const MenuScreen(),
    ];

    const labels = [
      'முகப்பு',
      'நாள்காட்டி',
      'பஞ்சாங்கம்',
      'விழாக்கள்',
      'மேலும்',
    ];

    const icons = [
      Icons.home_rounded,
      Icons.calendar_month_rounded,
      Icons.wb_twilight_rounded,
      Icons.celebration_rounded,
      Icons.menu_rounded,
    ];

    return Scaffold(
      backgroundColor: ink,
      body: IndexedStack(
        index: selected,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: _selectTab,
        destinations: List.generate(
          labels.length,
          (index) => NavigationDestination(
            icon: Icon(icons[index]),
            label: labels[index],
          ),
        ),
      ),
    );
  }
}

// More screen.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'நல்ல நேரம்',
        'நல்ல நேர விவரங்கள்',
        Icons.access_time_rounded,
      ),
      (
        'ராசிபலன்',
        'ராசி மற்றும் பலன்கள்',
        Icons.auto_awesome_rounded,
      ),
      (
        'நினைவூட்டல்கள்',
        'முக்கிய நாட்களை நினைவில் வைக்க',
        Icons.notifications_active_rounded,
      ),
      (
        'இடம்',
        'நகரம் மற்றும் இருப்பிட அமைப்புகள்',
        Icons.location_on_rounded,
      ),
      (
        'மொழி மாற்றம்',
        'தமிழ் / English',
        Icons.language_rounded,
      ),
      (
        'அமைப்புகள்',
        'செயலி அமைப்புகள்',
        Icons.settings_rounded,
      ),
      (
        'செயலியைப் பற்றி',
        'Tamil Nallkaati',
        Icons.info_outline_rounded,
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'மேலும்',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'உங்கள் நாள்காட்டி அமைப்புகள் மற்றும் கூடுதல் அம்சங்கள்',
            style: TextStyle(
              color: lavender,
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Card(
              child: ListTile(
                leading: Icon(
                  item.$3,
                  color: softGold,
                  size: 27,
                ),
                title: Text(
                  item.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(item.$2),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: softGold,
                ),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(item.$1),
                      content: Text(
                        '${item.$1} அம்சம் அடுத்த கட்டத்தில் '
                        'செயல்படுத்தப்படும்.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: const Text('மூடு'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
