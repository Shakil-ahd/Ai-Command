import 'package:flutter/material.dart';

class AppThemeData {
  final String id;
  final String name;
  final String emoji;
  final Color primaryColor;
  final Color accentColor;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;
  final Color bgDeep;
  final Color bgCard;
  final Color bgSurface;
  final Color bgElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final LinearGradient primaryGradient;
  final LinearGradient bgGradient;
  final List<Color> orbColors;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primaryColor,
    required this.accentColor,
    required this.successColor,
    required this.errorColor,
    required this.warningColor,
    required this.bgDeep,
    required this.bgCard,
    required this.bgSurface,
    required this.bgElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.primaryGradient,
    required this.bgGradient,
    required this.orbColors,
  });
}

class AppThemes {
  static const List<AppThemeData> allThemes = [
    defaultDark,
    pureWhite,
    moonrise,
    oceanWave,
    midnight,
    sunset,
    volcano,
    cherry,
    aurora,
    forest,
    arctic,
    lavender,
    cyberpunk,
    golden,
    ocean,
  ];

  static const defaultDark = AppThemeData(
    id: 'default_dark',
    name: 'Cosmic Dark',
    emoji: '🌌',
    primaryColor: Color(0xFF6C63FF),
    accentColor: Color(0xFF00D4FF),
    successColor: Color(0xFF00E676),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD600),
    bgDeep: Color(0xFF080818),
    bgCard: Color(0xFF0F0F2A),
    bgSurface: Color(0xFF161630),
    bgElevated: Color(0xFF1E1E3F),
    textPrimary: Color(0xFFEEEEFF),
    textSecondary: Color(0xFF9090BB),
    textHint: Color(0xFF55557A),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF080818), Color(0xFF0D0D28), Color(0xFF0A0A20)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF6C63FF), Color(0xFF00D4FF), Color(0xFF6C63FF)],
  );

  static const moonrise = AppThemeData(
    id: 'moonrise',
    name: 'Moonrise Night',
    emoji: '🌕',
    primaryColor: Color(0xFFCFD8DC),
    accentColor: Color(0xFF90A4AE),
    successColor: Color(0xFF69F0AE),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD740),
    bgDeep: Color(0xFF0A0E14),
    bgCard: Color(0xFF111822),
    bgSurface: Color(0xFF18202C),
    bgElevated: Color(0xFF1F2936),
    textPrimary: Color(0xFFECEFF1),
    textSecondary: Color(0xFF90A4AE),
    textHint: Color(0xFF546E7A),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFCFD8DC), Color(0xFF78909C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF0A0E14), Color(0xFF111822), Color(0xFF0D1118)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFFCFD8DC), Color(0xFFE8EAF6), Color(0xFF78909C)],
  );

  static const oceanWave = AppThemeData(
    id: 'ocean_wave',
    name: 'Ocean Wave',
    emoji: '🌊',
    primaryColor: Color(0xFF0288D1),
    accentColor: Color(0xFF4FC3F7),
    successColor: Color(0xFF00E676),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD740),
    bgDeep: Color(0xFF01131E),
    bgCard: Color(0xFF041E2E),
    bgSurface: Color(0xFF062838),
    bgElevated: Color(0xFF083342),
    textPrimary: Color(0xFFE1F5FE),
    textSecondary: Color(0xFF4FC3F7),
    textHint: Color(0xFF0288D1),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0277BD), Color(0xFF4FC3F7)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF01131E), Color(0xFF041E2E), Color(0xFF01131E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF0288D1), Color(0xFF4FC3F7), Color(0xFF01579B)],
  );

  static const volcano = AppThemeData(
    id: 'volcano',
    name: 'Volcano Fire',
    emoji: '🌋',
    primaryColor: Color(0xFFFF3D00),
    accentColor: Color(0xFFFF6E40),
    successColor: Color(0xFF00E676),
    errorColor: Color(0xFFFF1744),
    warningColor: Color(0xFFFFEA00),
    bgDeep: Color(0xFF1A0800),
    bgCard: Color(0xFF2A1008),
    bgSurface: Color(0xFF351810),
    bgElevated: Color(0xFF402018),
    textPrimary: Color(0xFFFFF3E0),
    textSecondary: Color(0xFFFF8A65),
    textHint: Color(0xFFBF5530),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFFF3D00), Color(0xFFFF6E40)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF1A0800), Color(0xFF2A1008), Color(0xFF1A0800)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFFFF3D00), Color(0xFFFF6E40), Color(0xFFDD2C00)],
  );

  static const arctic = AppThemeData(
    id: 'arctic',
    name: 'Arctic Snow',
    emoji: '❄️',
    primaryColor: Color(0xFF80D8FF),
    accentColor: Color(0xFFB3E5FC),
    successColor: Color(0xFF69F0AE),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD740),
    bgDeep: Color(0xFF0A1520),
    bgCard: Color(0xFF0F1E2D),
    bgSurface: Color(0xFF142636),
    bgElevated: Color(0xFF1A2F40),
    textPrimary: Color(0xFFE1F5FE),
    textSecondary: Color(0xFF81D4FA),
    textHint: Color(0xFF4BA3C7),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF80D8FF), Color(0xFFB3E5FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF0A1520), Color(0xFF0F1E2D), Color(0xFF0A1520)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF80D8FF), Color(0xFFB3E5FC), Color(0xFF4FC3F7)],
  );

  static const midnight = AppThemeData(
    id: 'midnight',
    name: 'Midnight Blue',
    emoji: '🌙',
    primaryColor: Color(0xFF3D5AFE),
    accentColor: Color(0xFF448AFF),
    successColor: Color(0xFF69F0AE),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD740),
    bgDeep: Color(0xFF050A18),
    bgCard: Color(0xFF0A1228),
    bgSurface: Color(0xFF101830),
    bgElevated: Color(0xFF162040),
    textPrimary: Color(0xFFE8EAFF),
    textSecondary: Color(0xFF7888BB),
    textHint: Color(0xFF455080),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF3D5AFE), Color(0xFF448AFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF050A18), Color(0xFF0A1228), Color(0xFF050A18)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF3D5AFE), Color(0xFF448AFF), Color(0xFF304FFE)],
  );

  static const ocean = AppThemeData(
    id: 'ocean',
    name: 'Deep Ocean',
    emoji: '🐚',
    primaryColor: Color(0xFF00BCD4),
    accentColor: Color(0xFF26C6DA),
    successColor: Color(0xFF00E5FF),
    errorColor: Color(0xFFFF6E6E),
    warningColor: Color(0xFFFFD54F),
    bgDeep: Color(0xFF031520),
    bgCard: Color(0xFF06202E),
    bgSurface: Color(0xFF0A2A38),
    bgElevated: Color(0xFF0E3545),
    textPrimary: Color(0xFFE0F7FA),
    textSecondary: Color(0xFF80DEEA),
    textHint: Color(0xFF4DB6AC),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF031520), Color(0xFF06202E), Color(0xFF031520)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF00BCD4), Color(0xFF26C6DA), Color(0xFF0097A7)],
  );

  static const aurora = AppThemeData(
    id: 'aurora',
    name: 'Aurora Borealis',
    emoji: '🌈',
    primaryColor: Color(0xFF00E676),
    accentColor: Color(0xFF00BFA5),
    successColor: Color(0xFF76FF03),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD600),
    bgDeep: Color(0xFF040F0A),
    bgCard: Color(0xFF081A12),
    bgSurface: Color(0xFF0C221A),
    bgElevated: Color(0xFF102D22),
    textPrimary: Color(0xFFE0FFF0),
    textSecondary: Color(0xFF80CBC4),
    textHint: Color(0xFF4DB6AC),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF040F0A), Color(0xFF081A12), Color(0xFF040F0A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF00E676), Color(0xFF00BFA5), Color(0xFF69F0AE)],
  );

  static const sunset = AppThemeData(
    id: 'sunset',
    name: 'Sunset Glow',
    emoji: '🌅',
    primaryColor: Color(0xFFFF6D00),
    accentColor: Color(0xFFFF9100),
    successColor: Color(0xFF00E676),
    errorColor: Color(0xFFFF1744),
    warningColor: Color(0xFFFFEA00),
    bgDeep: Color(0xFF140A04),
    bgCard: Color(0xFF1E1208),
    bgSurface: Color(0xFF28190C),
    bgElevated: Color(0xFF322010),
    textPrimary: Color(0xFFFFF3E0),
    textSecondary: Color(0xFFBB9066),
    textHint: Color(0xFF886644),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF140A04), Color(0xFF1E1208), Color(0xFF140A04)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFFFF6D00), Color(0xFFFF9100), Color(0xFFFF3D00)],
  );

  static const cherry = AppThemeData(
    id: 'cherry',
    name: 'Cherry Blossom',
    emoji: '🌸',
    primaryColor: Color(0xFFFF4081),
    accentColor: Color(0xFFFF80AB),
    successColor: Color(0xFF69F0AE),
    errorColor: Color(0xFFFF1744),
    warningColor: Color(0xFFFFD740),
    bgDeep: Color(0xFF140810),
    bgCard: Color(0xFF1E0E18),
    bgSurface: Color(0xFF281420),
    bgElevated: Color(0xFF321A28),
    textPrimary: Color(0xFFFFE8F0),
    textSecondary: Color(0xFFBB7090),
    textHint: Color(0xFF884466),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF140810), Color(0xFF1E0E18), Color(0xFF140810)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFFFF4081), Color(0xFFFF80AB), Color(0xFFE91E63)],
  );

  static const forest = AppThemeData(
    id: 'forest',
    name: 'Dark Forest',
    emoji: '🌲',
    primaryColor: Color(0xFF4CAF50),
    accentColor: Color(0xFF81C784),
    successColor: Color(0xFF00E676),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD600),
    bgDeep: Color(0xFF060E06),
    bgCard: Color(0xFF0C180C),
    bgSurface: Color(0xFF122012),
    bgElevated: Color(0xFF182818),
    textPrimary: Color(0xFFE8F5E9),
    textSecondary: Color(0xFF81C784),
    textHint: Color(0xFF558B57),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF060E06), Color(0xFF0C180C), Color(0xFF060E06)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF4CAF50), Color(0xFF81C784), Color(0xFF388E3C)],
  );

  static const lavender = AppThemeData(
    id: 'lavender',
    name: 'Lavender Dream',
    emoji: '💜',
    primaryColor: Color(0xFFB388FF),
    accentColor: Color(0xFFCE93D8),
    successColor: Color(0xFF69F0AE),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFD740),
    bgDeep: Color(0xFF0E0814),
    bgCard: Color(0xFF160E1E),
    bgSurface: Color(0xFF1E1428),
    bgElevated: Color(0xFF261A32),
    textPrimary: Color(0xFFF3E5F5),
    textSecondary: Color(0xFFAA80BB),
    textHint: Color(0xFF775588),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFB388FF), Color(0xFFCE93D8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF0E0814), Color(0xFF160E1E), Color(0xFF0E0814)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFFB388FF), Color(0xFFCE93D8), Color(0xFF9C27B0)],
  );

  static const cyberpunk = AppThemeData(
    id: 'cyberpunk',
    name: 'Cyberpunk Neon',
    emoji: '⚡',
    primaryColor: Color(0xFFE040FB),
    accentColor: Color(0xFF00E5FF),
    successColor: Color(0xFF76FF03),
    errorColor: Color(0xFFFF1744),
    warningColor: Color(0xFFFFEA00),
    bgDeep: Color(0xFF0A0012),
    bgCard: Color(0xFF12001E),
    bgSurface: Color(0xFF1A0028),
    bgElevated: Color(0xFF220032),
    textPrimary: Color(0xFFF5E6FF),
    textSecondary: Color(0xFFBB66DD),
    textHint: Color(0xFF8844AA),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF0A0012), Color(0xFF12001E), Color(0xFF0A0012)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFFE040FB), Color(0xFF00E5FF), Color(0xFFD500F9)],
  );

  static const golden = AppThemeData(
    id: 'golden',
    name: 'Royal Gold',
    emoji: '👑',
    primaryColor: Color(0xFFFFD700),
    accentColor: Color(0xFFFFB300),
    successColor: Color(0xFF00E676),
    errorColor: Color(0xFFFF5252),
    warningColor: Color(0xFFFFEA00),
    bgDeep: Color(0xFF100E04),
    bgCard: Color(0xFF1A1608),
    bgSurface: Color(0xFF221E0C),
    bgElevated: Color(0xFF2A2610),
    textPrimary: Color(0xFFFFF8E1),
    textSecondary: Color(0xFFBBA866),
    textHint: Color(0xFF887744),
    primaryGradient: LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFF100E04), Color(0xFF1A1608), Color(0xFF100E04)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFFFFD700), Color(0xFFFFB300), Color(0xFFFFC107)],
  );

  static const pureWhite = AppThemeData(
    id: 'pure_white',
    name: 'Clean White',
    emoji: '☀️',
    primaryColor: Color(0xFF4A6CF7),
    accentColor: Color(0xFF6C63FF),
    successColor: Color(0xFF22C55E),
    errorColor: Color(0xFFEF4444),
    warningColor: Color(0xFFF59E0B),
    bgDeep: Color(0xFFF5F7FA),
    bgCard: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFF0F2F5),
    bgElevated: Color(0xFFE8EBF0),
    textPrimary: Color(0xFF1A1D26),
    textSecondary: Color(0xFF5A6070),
    textHint: Color(0xFF9AA0B0),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF4A6CF7), Color(0xFF6C63FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    bgGradient: LinearGradient(
      colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF), Color(0xFFF5F7FA)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    orbColors: [Color(0xFF4A6CF7), Color(0xFF6C63FF), Color(0xFF818CF8)],
  );

  static AppThemeData getThemeById(String id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => defaultDark,
    );
  }
}
