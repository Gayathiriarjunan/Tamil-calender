import 'package:flutter/material.dart';

import '../app/theme.dart';

class RasiPalanScreen extends StatefulWidget {
  const RasiPalanScreen({super.key});

  @override
  State<RasiPalanScreen> createState() => _RasiPalanScreenState();
}

class _RasiPalanScreenState extends State<RasiPalanScreen> {
  int selectedIndex = 0;

  static const List<Map<String, String>> signs = [
    {
      'name': 'மேஷம்',
      'english': 'Aries',
      'symbol': '♈',
    },
    {
      'name': 'ரிஷபம்',
      'english': 'Taurus',
      'symbol': '♉',
    },
    {
      'name': 'மிதுனம்',
      'english': 'Gemini',
      'symbol': '♊',
    },
    {
      'name': 'கடகம்',
      'english': 'Cancer',
      'symbol': '♋',
    },
    {
      'name': 'சிம்மம்',
      'english': 'Leo',
      'symbol': '♌',
    },
    {
      'name': 'கன்னி',
      'english': 'Virgo',
      'symbol': '♍',
    },
    {
      'name': 'துலாம்',
      'english': 'Libra',
      'symbol': '♎',
    },
    {
      'name': 'விருச்சிகம்',
      'english': 'Scorpio',
      'symbol': '♏',
    },
    {
      'name': 'தனுசு',
      'english': 'Sagittarius',
      'symbol': '♐',
    },
    {
      'name': 'மகரம்',
      'english': 'Capricorn',
      'symbol': '♑',
    },
    {
      'name': 'கும்பம்',
      'english': 'Aquarius',
      'symbol': '♒',
    },
    {
      'name': 'மீனம்',
      'english': 'Pisces',
      'symbol': '♓',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sign = signs[selectedIndex];

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text('ராசிபலன்'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'உங்கள் ராசியைத் தேர்ந்தெடுக்கவும்',
              style: TextStyle(
                color: softGold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'பன்னிரண்டு ராசிகள்',
              style: TextStyle(
                color: lavender,
                fontSize: 13,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: signs.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 9,
                crossAxisSpacing: 9,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final item = signs[index];
                final isSelected = index == selectedIndex;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF382052),
                            Color(0xFF21112F),
                          ],
                        ),
                        border: Border.all(
                          color: isSelected
                              ? softGold
                              : softGold.withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['symbol']!,
                            style: const TextStyle(
                              color: softGold,
                              fontSize: 26,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['name']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? softGold
                                  : cream,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['english']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: lavender,
                              fontSize: 10,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF321653),
                    Color(0xFF1B0D30),
                  ],
                ),
                border: Border.all(
                  color: softGold.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        sign['symbol']!,
                        style: const TextStyle(
                          color: softGold,
                          fontSize: 34,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sign['name']!,
                              style: const TextStyle(
                                color: softGold,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              sign['english']!,
                              style: const TextStyle(
                                color: lavender,
                                fontSize: 12,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'தினசரி ராசிபலன்',
                    style: TextStyle(
                      color: cream,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'சரிபார்க்கப்பட்ட தினசரி ராசிபலன் தரவு '
                    'இன்னும் இணைக்கப்படவில்லை.',
                    style: TextStyle(
                      color: lavender,
                      fontSize: 14,
                      height: 1.6,
                      decoration: TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Divider(
                    color: lavender,
                    height: 1,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'உண்மையான தினசரி பலன்களைப் பெறுவதற்கு '
                    'நம்பகமான ராசிபலன் தரவு மூலத்தை இணைக்கவும்.',
                    style: TextStyle(
                      color: cream,
                      fontSize: 12,
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}