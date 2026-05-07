import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary   = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFF16213E);
  static const Color surface   = Color(0xFF0F3460);
  static const Color accent    = Color(0xFFE94560);
  static const Color highlight = Color(0xFFF5A623);
  static const Color success   = Color(0xFF27C93F);
  static const Color error     = Color(0xFFFF4444);
  static const Color textLight = Color(0xFFEAEAEA);
  static const Color textMuted = Color(0xFF8892A4);
  static const Color white     = Color(0xFFFFFFFF);

  static Color cardGlass       = Colors.white.withValues(alpha: 0.05);
  static Color cardGlassBorder = Colors.white.withValues(alpha: 0.10);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayXL = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 48,
    color: AppColors.textLight,
    letterSpacing: 2,
  );
  static const TextStyle displayLG = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 36,
    color: AppColors.textLight,
    letterSpacing: 1.5,
  );
  static const TextStyle displayMD = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 28,
    color: AppColors.textLight,
    letterSpacing: 1,
  );
  static const TextStyle displaySM = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 20,
    color: AppColors.textLight,
    letterSpacing: 1,
  );

  static const TextStyle bodyLG = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );
  static const TextStyle bodyMD = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );
  static const TextStyle bodySM = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
  );
  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );
  static const TextStyle bodyBoldLG = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static const TextStyle statXL = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );
  static const TextStyle statLG = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );
  static const TextStyle statMD = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );
  static const TextStyle statSM = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
  static const TextStyle statXS = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 16;
  static const double lg   = 24;
  static const double full = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
  static const BorderRadius sm_  = BorderRadius.all(Radius.circular(sm));
}

class AppGradients {
  AppGradients._();

  static const LinearGradient background = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient card = LinearGradient(
    colors: [Color(0xFF1E2A45), AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accent, Color(0xFFB83050)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient highlight = LinearGradient(
    colors: [AppColors.highlight, Color(0xFFD4891F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2),
  ];

  static List<BoxShadow> accentGlow = glow(AppColors.accent);
}

// Avatar options — 12 emojis matching RunApp
const List<String> kAvatarOptions = [
  '🏃', '⚡', '🦅', '🔥', '🐺', '💎',
  '🌙', '🎯', '🦁', '⚔️', '👑', '🌊',
];

// Activity types
const String kActivityRunning = 'running';
const String kActivityWalking = 'walking';

// MET values for calorie calculation
const double kMetRunning = 9.8;
const double kMetWalking = 3.5;

// Step estimates per km (fallback when pedometer unavailable)
const int kStepsPerKmRunning = 1300;
const int kStepsPerKmWalking = 1400;

// XP formula constants
const double kXpPerMinute  = 10.0;
const double kXpPerKm      = 20.0;
const int    kXpToNextBase = 1000;
const double kXpLevelMultiplier = 1.3;

// Bengaluru map center
const double kBengaluruLat = 12.9716;
const double kBengaluruLng = 77.5946;
const double kDefaultMapZoom = 13.0;

// Secure storage keys
const String kKeyAccessToken  = 'runworld_access_token';
const String kKeyRefreshToken = 'runworld_refresh_token';

// SharedPreferences keys
const String kPrefUser     = 'runworld_user';
const String kPrefSettings = 'runworld_settings';
