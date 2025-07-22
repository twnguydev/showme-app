// mobile/lib/core/services/storage_service.dart
// Modifiez StorageService pour sérialiser en JSON au lieu d'utiliser Hive directement

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class StorageService {
  static Box? _box;
  static const String _boxName = 'showme_storage';

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // Méthodes pour l'authentification
  static Future<void> setToken(String token) async {
    await _box?.put('auth_token', token);
  }

  static Future<String?> getToken() async {
    return _box?.get('auth_token');
  }

  static Future<void> clearToken() async {
    await _box?.delete('auth_token');
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    await _box?.put('refresh_token', refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return _box?.get('refresh_token');
  }

  static Future<void> clearRefreshToken() async {
    await _box?.delete('refresh_token');
  }

  static Future<void> setTokenExpiration(DateTime expiration) async {
    await _box?.put('token_expiration', expiration.toIso8601String());
  }

  static Future<DateTime?> getTokenExpiration() async {
    final expirationString = _box?.get('token_expiration');
    if (expirationString != null) {
      return DateTime.parse(expirationString);
    }
    return null;
  }

  static Future<void> clearTokenExpiration() async {
    await _box?.delete('token_expiration');
  }

  // Méthodes pour l'utilisateur - SÉRIALISATION JSON
  static Future<void> setUser(Map<String, dynamic> userData) async {
    // Convertir en JSON string avant de sauvegarder
    final jsonString = jsonEncode(userData);
    await _box?.put('user_data', jsonString);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final jsonString = _box?.get('user_data');
    if (jsonString != null && jsonString is String) {
      try {
        // Décoder le JSON string
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        print('Erreur décodage user data: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUser() async {
    await _box?.delete('user_data');
  }

  // Méthodes génériques
  static Future<void> setValue(String key, dynamic value) async {
    if (value is Map<String, dynamic> || value is List) {
      // Sérialiser les objets complexes en JSON
      await _box?.put(key, jsonEncode(value));
    } else {
      await _box?.put(key, value);
    }
  }

  static T? getValue<T>(String key) {
    final value = _box?.get(key);
    
    if (value is String && (T == Map || T == List)) {
      try {
        return jsonDecode(value) as T;
      } catch (e) {
        print('Erreur décodage $key: $e');
        return null;
      }
    }
    
    return value as T?;
  }

  static Future<void> removeValue(String key) async {
    await _box?.delete(key);
  }

  static Future<void> clear() async {
    await _box?.clear();
  }

  static bool hasKey(String key) {
    return _box?.containsKey(key) ?? false;
  }
}