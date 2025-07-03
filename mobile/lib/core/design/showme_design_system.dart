// mobile/lib/core/design/showme_design_system.dart
import 'package:flutter/material.dart';

/// 🎨 Système de design Showme
/// Identité visuelle premium pour l'ère digitale
class ShowmeDesign {
  // 🌈 PALETTE DE COULEURS PRINCIPALE
  // Inspirée des cartes holographiques et de l'identité premium
  static const Color primaryPurple = Color(0xFF6366F1);      // Indigo moderne
  static const Color primaryBlue = Color(0xFF3B82F6);        // Bleu tech
  static const Color primaryTeal = Color(0xFF06B6D4);        // Cyan moderne
  static const Color primaryEmerald = Color(0xFF10B981);     // Vert succès
  static const Color primaryAmber = Color(0xFFF59E0B);       // Orange premium
  static const Color primaryRose = Color(0xFFEC4899);        // Rose vibrant

  // 🖤 COULEURS SYSTÈME
  static const Color neutral900 = Color(0xFF111827);         // Noir principal
  static const Color neutral800 = Color(0xFF1F2937);         // Gris très foncé
  static const Color neutral700 = Color(0xFF374151);         // Gris foncé
  static const Color neutral600 = Color(0xFF4B5563);         // Gris moyen
  static const Color neutral500 = Color(0xFF6B7280);         // Gris
  static const Color neutral400 = Color(0xFF9CA3AF);         // Gris clair
  static const Color neutral300 = Color(0xFFD1D5DB);         // Gris très clair
  static const Color neutral200 = Color(0xFFE5E7EB);         // Gris ultra clair
  static const Color neutral100 = Color(0xFFF3F4F6);         // Presque blanc
  static const Color neutral50 = Color(0xFFF9FAFB);          // Blanc cassé
  static const Color white = Color(0xFFFFFFFF);              // Blanc pur

  // 🌊 DÉGRADÉS SIGNATURE
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryBlue],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryTeal, primaryEmerald],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryAmber, primaryRose],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neutral800, neutral900],
  );

  // ✨ EFFETS VISUELS
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.2),
      blurRadius: 32,
      offset: const Offset(0, 16),
      spreadRadius: 4,
    ),
    BoxShadow(
      color: primaryBlue.withOpacity(0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // 📏 ESPACEMENTS
  static const double spacing2xs = 2;
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;
  static const double spacing3xl = 64;

  // 📐 RAYONS DE BORDURE
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radius2xl = 32;
  static const double radiusFull = 9999;

  // 🔤 TYPOGRAPHIE
  static const String fontFamily = 'SF Pro Display'; // iOS natif, fallback système

  // Tailles de police
  static const double text2xs = 10;
  static const double textXs = 12;
  static const double textSm = 14;
  static const double textBase = 16;
  static const double textLg = 18;
  static const double textXl = 20;
  static const double text2xl = 24;
  static const double text3xl = 30;
  static const double text4xl = 36;
  static const double text5xl = 48;
  static const double text6xl = 60;

  // Styles de texte
  static TextStyle get h1 => const TextStyle(
    fontSize: text4xl,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.02,
  );

  static TextStyle get h2 => const TextStyle(
    fontSize: text3xl,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01,
  );

  static TextStyle get h3 => const TextStyle(
    fontSize: text2xl,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle get h4 => const TextStyle(
    fontSize: textXl,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.005,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: textLg,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: textBase,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: textSm,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: textXs,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static TextStyle get button => const TextStyle(
    fontSize: textBase,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.025,
  );

  // 🎯 MÉTHODES UTILITAIRES
  static Color getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
      case 'purple':
        return primaryPurple;
      case 'blue':
        return primaryBlue;
      case 'teal':
        return primaryTeal;
      case 'emerald':
        return primaryEmerald;
      case 'amber':
        return primaryAmber;
      case 'rose':
        return primaryRose;
      default:
        return primaryPurple;
    }
  }

  static LinearGradient getThemeGradient(String theme) {
    switch (theme.toLowerCase()) {
      case 'purple':
      case 'blue':
        return primaryGradient;
      case 'teal':
      case 'emerald':
        return successGradient;
      case 'amber':
      case 'rose':
        return warmGradient;
      case 'dark':
        return darkGradient;
      default:
        return primaryGradient;
    }
  }

  // 🌟 ANIMATION CURVES
  static const Curve primaryCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;

  // ⏱️ DURÉES D'ANIMATION
  static const Duration fastDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);

  // 📱 BREAKPOINTS RESPONSIVE
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
}

// 🎨 Extensions pour faciliter l'usage
extension ShowmeColorExtension on Color {
  Color get onColor => computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  
  Color withOpacity10() => withOpacity(0.1);
  Color withOpacity20() => withOpacity(0.2);
  Color withOpacity50() => withOpacity(0.5);
  Color withOpacity80() => withOpacity(0.8);
}

extension ShowmeContextExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < ShowmeDesign.mobileBreakpoint;
  bool get isTablet => MediaQuery.of(this).size.width >= ShowmeDesign.mobileBreakpoint && 
                     MediaQuery.of(this).size.width < ShowmeDesign.desktopBreakpoint;
  bool get isDesktop => MediaQuery.of(this).size.width >= ShowmeDesign.desktopBreakpoint;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}