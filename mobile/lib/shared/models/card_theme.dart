// mobile/lib/shared/models/card_theme.dart
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CardTheme {
  @JsonValue('purple')
  purple,
  @JsonValue('blue')
  blue,
  @JsonValue('teal')
  teal,
  @JsonValue('green')
  green,
  @JsonValue('orange')
  orange,
  @JsonValue('red')
  red,
  @JsonValue('pink')
  pink,
  @JsonValue('indigo')
  indigo,
  @JsonValue('emerald')
  emerald,
  @JsonValue('amber')
  amber,
}

class CardThemeHelper {
  static String getDisplayName(CardTheme theme) {
    switch (theme) {
      case CardTheme.purple:
        return 'Violet';
      case CardTheme.blue:
        return 'Bleu';
      case CardTheme.teal:
        return 'Sarcelle';
      case CardTheme.green:
        return 'Vert';
      case CardTheme.orange:
        return 'Orange';
      case CardTheme.red:
        return 'Rouge';
      case CardTheme.pink:
        return 'Rose';
      case CardTheme.indigo:
        return 'Indigo';
      case CardTheme.emerald:
        return 'Émeraude';
      case CardTheme.amber:
        return 'Ambre';
    }
  }

  static Color getPrimaryColor(CardTheme theme) {
    switch (theme) {
      case CardTheme.purple:
        return const Color(0xFF6366f1);
      case CardTheme.blue:
        return const Color(0xFF3b82f6);
      case CardTheme.teal:
        return const Color(0xFF14b8a6);
      case CardTheme.green:
        return const Color(0xFF10b981);
      case CardTheme.orange:
        return const Color(0xFFf59e0b);
      case CardTheme.red:
        return const Color(0xFFef4444);
      case CardTheme.pink:
        return const Color(0xFFec4899);
      case CardTheme.indigo:
        return const Color(0xFF4f46e5);
      case CardTheme.emerald:
        return const Color(0xFF059669);
      case CardTheme.amber:
        return const Color(0xFFd97706);
    }
  }

  static Color getSecondaryColor(CardTheme theme) {
    switch (theme) {
      case CardTheme.purple:
        return const Color(0xFF8b5cf6);
      case CardTheme.blue:
        return const Color(0xFF60a5fa);
      case CardTheme.teal:
        return const Color(0xFF2dd4bf);
      case CardTheme.green:
        return const Color(0xFF34d399);
      case CardTheme.orange:
        return const Color(0xFFfbbf24);
      case CardTheme.red:
        return const Color(0xFFf87171);
      case CardTheme.pink:
        return const Color(0xFFf472b6);
      case CardTheme.indigo:
        return const Color(0xFF6366f1);
      case CardTheme.emerald:
        return const Color(0xFF10b981);
      case CardTheme.amber:
        return const Color(0xFFfbbf24);
    }
  }

  static LinearGradient getGradient(CardTheme theme) {
    final primary = getPrimaryColor(theme);
    final secondary = getSecondaryColor(theme);
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary,
        secondary,
        primary.withOpacity(0.8),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }

  static List<BoxShadow> getShadows(CardTheme theme) {
    final primary = getPrimaryColor(theme);
    final secondary = getSecondaryColor(theme);
    
    return [
      BoxShadow(
        color: primary.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: 2,
      ),
      BoxShadow(
        color: secondary.withOpacity(0.2),
        blurRadius: 30,
        offset: const Offset(0, 15),
        spreadRadius: 5,
      ),
    ];
  }

  static Color getTextColor(CardTheme theme) {
    switch (theme) {
      case CardTheme.amber:
      case CardTheme.orange:
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  static CardTheme fromString(String themeString) {
    try {
      return CardTheme.values.firstWhere(
        (theme) => theme.name == themeString.toLowerCase(),
      );
    } catch (e) {
      return CardTheme.purple;
    }
  }

  static List<CardTheme> get availableThemes => CardTheme.values;
}