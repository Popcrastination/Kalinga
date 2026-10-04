import 'package:flutter/material.dart';
import 'constants/app_spacing.dart';

/// Kalinga's app-wide theme, built from the Design System v2 worksheet.
/// Light mode only for this term — see the design system doc for why.
final ThemeData kalingaTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFFFF4E1), // Background
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF91AE6E), // Primary
    brightness: Brightness.light,
  ).copyWith(
    // ColorScheme.fromSeed derives its own tonal shade from the seed —
    // it does NOT guarantee `primary` equals the seed color exactly.
    // Pin it explicitly here so every `scheme.primary` use (app bars,
    // buttons, borders) renders the literal #91AE6E, not a derived tone.
    primary: const Color(0xFF91AE6E),
    // #91AE6E is light enough that white text/icons on it fail contrast
    // (~2.5:1, under the 4.5:1 minimum) — this dark green passes at ~5.6:1.
    // Use `colorScheme.onPrimary` (never Colors.white) for anything drawn
    // on top of a primary-colored surface (app bars, filled buttons).
    onPrimary: const Color(0xFF1A312C),
    secondary: const Color(0xFF428475), // Secondary / Accent
    error: const Color(0xFFFF0052), // Error
    surface: const Color(0xFFFFFFFF), // Surface (cards, fields)
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 16),
    labelSmall: TextStyle(fontSize: 12, color: Colors.grey),
  ),
  cardTheme: const CardThemeData(
    margin: EdgeInsets.all(AppSpacing.md),
    color: Color(0xFFFFFFFF),
    elevation: 1,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF91AE6E),
      foregroundColor: const Color(0xFF1A312C),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFFF4E1),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm + 4,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE2D9C8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE2D9C8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF91AE6E), width: 1.5),
    ),
  ),
);
