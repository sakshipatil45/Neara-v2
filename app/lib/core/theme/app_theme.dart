import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme() {
  // Monochrome base theme (black & white focus)
  const primaryBackground = Color(0xFFFFFFFF);
  const secondaryBackground = Color(0xFFF5F5F5);
  const emergencyAccent = Color(0xFFEF4444);

  // Using rounded font family (Quicksand)
  final baseTextTheme = GoogleFonts.quicksandTextTheme(
    const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
  );

  final colorScheme = const ColorScheme.light(
    background: primaryBackground,
    surface: secondaryBackground,
    primary: Colors.black,
    secondary: Colors.black,
    error: emergencyAccent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: primaryBackground,
    textTheme: baseTextTheme.apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: primaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: primaryBackground),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

// Gradient backgrounds for consistent use across the app
class AppGradients {
  // General app background: soft grayscale
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
  );

  // Default accent surfaces (buttons, chips etc.) in black tones
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111827), Color(0xFF000000)],
  );

  // Card background
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  );

  // Voice agent screen background: white + blue mix
  static const agentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFE0F2FE), // light blue
      Color(0xFFBFDBFE), // slightly deeper blue
    ],
  );
}
