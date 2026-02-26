import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const textColor = Colors.black87;
  const border = Color(0xFFE7E7E7);
  const surface = Color(0xFFF8F7F5);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFFFEFC),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF111111),
      onPrimary: Colors.white,
      secondary: Color(0xFFB48A5A),
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: textColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: textColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
      surfaceTintColor: surface,
    ),
  );
}
