import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_themes.dart';

class AppTheme {
  AppTheme._();

  static AppThemeData _current = AppThemes.defaultDark;

  static AppThemeData get current => _current;

  static void setCurrent(AppThemeData theme) {
    _current = theme;
  }

  static Color get primaryColor => _current.primaryColor;
  static Color get accentColor => _current.accentColor;
  static Color get successColor => _current.successColor;
  static Color get errorColor => _current.errorColor;
  static Color get warningColor => _current.warningColor;

  static Color get bgDeep => _current.bgDeep;
  static Color get bgCard => _current.bgCard;
  static Color get bgSurface => _current.bgSurface;
  static Color get bgElevated => _current.bgElevated;

  static Color get textPrimary => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;
  static Color get textHint => _current.textHint;

  static LinearGradient get primaryGradient => _current.primaryGradient;
  static LinearGradient get bgGradient => _current.bgGradient;
  static List<Color> get orbColors => _current.orbColors;

  static bool get isLightTheme => _current.id == 'pure_white';

  static ThemeData get darkTheme {
    final isLight = isLightTheme;
    final base = isLight
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bgDeep,
      colorScheme: isLight
          ? ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor,
              surface: bgCard,
              error: errorColor,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: textPrimary,
            )
          : ColorScheme.dark(
              primary: primaryColor,
              secondary: accentColor,
              surface: bgCard,
              error: errorColor,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: textPrimary,
            ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textHint.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        hintStyle: TextStyle(color: textHint, fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
