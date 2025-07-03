// mobile/lib/core/utils/app_theme.dart (VERSION SHOWME V2)
import 'package:flutter/material.dart';
import '../design/showme_design_system.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Couleurs principales basées sur le design system
      colorScheme: ColorScheme.light(
        primary: ShowmeDesign.primaryPurple,
        secondary: ShowmeDesign.primaryTeal,
        surface: ShowmeDesign.white,
        background: ShowmeDesign.neutral50,
        error: ShowmeDesign.primaryRose,
        onPrimary: ShowmeDesign.white,
        onSecondary: ShowmeDesign.white,
        onSurface: ShowmeDesign.neutral900,
        onBackground: ShowmeDesign.neutral900,
      ),
      
      scaffoldBackgroundColor: ShowmeDesign.neutral50,
      
      // AppBar avec le style Showme
      appBarTheme: AppBarTheme(
        backgroundColor: ShowmeDesign.white,
        foregroundColor: ShowmeDesign.neutral900,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ShowmeDesign.h3.copyWith(
          color: ShowmeDesign.neutral900,
        ),
        iconTheme: const IconThemeData(
          color: ShowmeDesign.neutral900,
        ),
      ),
      
      // Cards avec le style premium
      cardTheme: CardTheme(
        color: ShowmeDesign.white,
        elevation: 0,
        shadowColor: ShowmeDesign.primaryPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
        ),
      ),
      
      // Boutons avec gradients
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShowmeDesign.primaryPurple,
          foregroundColor: ShowmeDesign.white,
          elevation: 0,
          shadowColor: ShowmeDesign.primaryPurple.withOpacity(0.3),
          padding: EdgeInsets.symmetric(
            horizontal: ShowmeDesign.spacingLg,
            vertical: ShowmeDesign.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          ),
          textStyle: ShowmeDesign.button.copyWith(
            color: ShowmeDesign.white,
          ),
        ),
      ),
      
      // Input fields modernes
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShowmeDesign.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
            color: ShowmeDesign.neutral300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
            color: ShowmeDesign.primaryPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
            color: ShowmeDesign.primaryRose,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(ShowmeDesign.spacingMd),
        labelStyle: ShowmeDesign.bodyMedium.copyWith(
          color: ShowmeDesign.neutral600,
        ),
        hintStyle: ShowmeDesign.bodyMedium.copyWith(
          color: ShowmeDesign.neutral500,
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ShowmeDesign.primaryPurple,
        foregroundColor: ShowmeDesign.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ShowmeDesign.white,
        selectedItemColor: ShowmeDesign.primaryPurple,
        unselectedItemColor: ShowmeDesign.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: ShowmeDesign.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: ShowmeDesign.caption,
      ),
      
      // Typographie
      textTheme: TextTheme(
        displayLarge: ShowmeDesign.h1.copyWith(color: ShowmeDesign.neutral900),
        displayMedium: ShowmeDesign.h2.copyWith(color: ShowmeDesign.neutral900),
        displaySmall: ShowmeDesign.h3.copyWith(color: ShowmeDesign.neutral900),
        bodyLarge: ShowmeDesign.bodyLarge.copyWith(color: ShowmeDesign.neutral800),
        bodyMedium: ShowmeDesign.bodyMedium.copyWith(color: ShowmeDesign.neutral700),
        bodySmall: ShowmeDesign.bodySmall.copyWith(color: ShowmeDesign.neutral600),
        labelMedium: ShowmeDesign.caption.copyWith(color: ShowmeDesign.neutral600),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: ShowmeDesign.neutral200,
        thickness: 1,
        space: ShowmeDesign.spacingMd,
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ShowmeDesign.neutral800,
        contentTextStyle: ShowmeDesign.bodyMedium.copyWith(
          color: ShowmeDesign.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: ShowmeDesign.primaryPurple,
        secondary: ShowmeDesign.primaryTeal,
        surface: ShowmeDesign.neutral800,
        background: ShowmeDesign.neutral900,
        error: ShowmeDesign.primaryRose,
        onPrimary: ShowmeDesign.white,
        onSecondary: ShowmeDesign.white,
        onSurface: ShowmeDesign.neutral100,
        onBackground: ShowmeDesign.neutral100,
      ),
      
      scaffoldBackgroundColor: ShowmeDesign.neutral900,
      
      appBarTheme: AppBarTheme(
        backgroundColor: ShowmeDesign.neutral800,
        foregroundColor: ShowmeDesign.neutral100,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ShowmeDesign.h3.copyWith(
          color: ShowmeDesign.neutral100,
        ),
        iconTheme: const IconThemeData(
          color: ShowmeDesign.neutral100,
        ),
      ),
      
      cardTheme: CardTheme(
        color: ShowmeDesign.neutral800,
        elevation: 0,
        shadowColor: ShowmeDesign.primaryPurple.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusLg),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShowmeDesign.primaryPurple,
          foregroundColor: ShowmeDesign.white,
          elevation: 0,
          shadowColor: ShowmeDesign.primaryPurple.withOpacity(0.3),
          padding: EdgeInsets.symmetric(
            horizontal: ShowmeDesign.spacingLg,
            vertical: ShowmeDesign.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          ),
          textStyle: ShowmeDesign.button.copyWith(
            color: ShowmeDesign.white,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShowmeDesign.neutral700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
            color: ShowmeDesign.neutral600,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
            color: ShowmeDesign.primaryPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
          borderSide: BorderSide(
            color: ShowmeDesign.primaryRose,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(ShowmeDesign.spacingMd),
        labelStyle: ShowmeDesign.bodyMedium.copyWith(
          color: ShowmeDesign.neutral400,
        ),
        hintStyle: ShowmeDesign.bodyMedium.copyWith(
          color: ShowmeDesign.neutral500,
        ),
      ),
      
      textTheme: TextTheme(
        displayLarge: ShowmeDesign.h1.copyWith(color: ShowmeDesign.neutral100),
        displayMedium: ShowmeDesign.h2.copyWith(color: ShowmeDesign.neutral100),
        displaySmall: ShowmeDesign.h3.copyWith(color: ShowmeDesign.neutral100),
        bodyLarge: ShowmeDesign.bodyLarge.copyWith(color: ShowmeDesign.neutral200),
        bodyMedium: ShowmeDesign.bodyMedium.copyWith(color: ShowmeDesign.neutral300),
        bodySmall: ShowmeDesign.bodySmall.copyWith(color: ShowmeDesign.neutral400),
        labelMedium: ShowmeDesign.caption.copyWith(color: ShowmeDesign.neutral400),
      ),
      
      dividerTheme: DividerThemeData(
        color: ShowmeDesign.neutral700,
        thickness: 1,
        space: ShowmeDesign.spacingMd,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ShowmeDesign.neutral200,
        contentTextStyle: ShowmeDesign.bodyMedium.copyWith(
          color: ShowmeDesign.neutral900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShowmeDesign.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Méthodes utilitaires pour les couleurs de thème
  static Color getThemeColor(String theme) => ShowmeDesign.getThemeColor(theme);
  static LinearGradient getThemeGradient(String theme) => ShowmeDesign.getThemeGradient(theme);
}