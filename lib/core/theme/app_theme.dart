import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette — Deep Space Minimalist with Crimson Hazard touches.
///
/// Evokes a sleek, high-tech spaceship interface:
/// - Background: Deep Void Obsidian (`#08080C`)
/// - Surfaces: Cosmic slate & frosted glass tones (`#111119`, `#181824`)
/// - Borders: Subtle starlight glow (`#2A2A3D`)
/// - Primary text: Pure Starlight White (`#FFFFFF`, `#F0F0F5`)
/// - Secondary text: Celestial Silver (`#9B9BAF`, `#606072`)
/// - Hazard / Exit: Crimson Hazard (`#FF3B30`) strictly for delete, exit, and emergency actions.
abstract final class AppColors {
  // Deep Space Backgrounds
  static const Color background = Color(0xFF08080C);
  static const Color surface = Color(0xFF111119);
  static const Color surfaceLight = Color(0xFF191925);
  static const Color surfaceBorder = Color(0xFF26263B);
  static const Color surfaceGlow = Color(0xFF383856);

  // Starlight Monochrome text & elements
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFFA2A2B6);
  static const Color textMuted = Color(0xFF626278);
  static const Color divider = Color(0xFF1F1F30);

  // Crimson Hazard (Strictly for exit, delete & emergency actions)
  static const Color danger = Color(0xFFFF3B30);
  static const Color dangerHover = Color(0xFFE02E24);
  static const Color dangerBg = Color(0x22FF3B30);

  // Sleek celestial grayscale tones for avatars
  static const List<int> avatarGrays = <int>[
    0xFF2D2D42,
    0xFF3E3E58,
    0xFF4E4E6E,
    0xFF5F5F85,
    0xFF353D4D,
    0xFF424D61,
    0xFF52607A,
    0xFF252C3A,
  ];
}

/// Central theme configuration for Uhjiyyah (أُحْجِيَّة).
abstract final class AppTheme {
  /// Deep Space Minimalist Dark Theme
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.pureWhite,
        onPrimary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.pureWhite,
      ),
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.pureWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.pureWhite, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pureWhite,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.surfaceLight,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          textStyle: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}
