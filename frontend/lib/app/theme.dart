import 'package:flutter/material.dart';

// App colors
const ink = Color(0xFF08070D);
const deepPurple = Color(0xFF180D2E);
const royalPurple = Color(0xFF6C35B5);
const lavender = Color(0xFFB89AFF);
const softGold = Color(0xFFE7C982);
const cream = Color(0xFFF7F2FF);

ThemeData buildTamilTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: royalPurple,
    brightness: Brightness.dark,
    surface: const Color(0xFF211238),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ink,

    fontFamily: null,

    appBarTheme: const AppBarTheme(
      backgroundColor: ink,
      foregroundColor: cream,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: cream,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF160D24),
      indicatorColor: royalPurple.withValues(alpha: 0.55),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF211238),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF211333),
      titleTextStyle: TextStyle(
        color: softGold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
      contentTextStyle: TextStyle(
        color: cream,
        fontSize: 14,
        height: 1.5,
        decoration: TextDecoration.none,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: cream,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
      displayMedium: TextStyle(
        color: cream,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
      headlineLarge: TextStyle(
        color: cream,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
      headlineMedium: TextStyle(
        color: cream,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
      headlineSmall: TextStyle(
        color: cream,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
      titleLarge: TextStyle(
        color: cream,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.none,
      ),
      titleMedium: TextStyle(
        color: cream,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      ),
      titleSmall: TextStyle(
        color: cream,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      ),
      bodyLarge: TextStyle(
        color: cream,
        fontSize: 16,
        height: 1.4,
        decoration: TextDecoration.none,
      ),
      bodyMedium: TextStyle(
        color: cream,
        fontSize: 14,
        height: 1.4,
        decoration: TextDecoration.none,
      ),
      bodySmall: TextStyle(
        color: lavender,
        fontSize: 12,
        height: 1.4,
        decoration: TextDecoration.none,
      ),
      labelLarge: TextStyle(
        color: cream,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
      ),
      labelMedium: TextStyle(
        color: lavender,
        fontSize: 12,
        decoration: TextDecoration.none,
      ),
      labelSmall: TextStyle(
        color: lavender,
        fontSize: 11,
        decoration: TextDecoration.none,
      ),
    ),
  );
}