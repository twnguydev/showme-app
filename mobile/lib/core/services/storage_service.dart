// mobile/lib/core/services/storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static late Box _box;
  
  // Clés pour le stockage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpirationKey = 'token_expiration';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _biometricKey = 'biometric_enabled';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _analyticsKey = 'analytics_enabled';

  /// Initialise le service de stockage
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('showme_storage');
  }

  /// Ferme le service de stockage
  static Future<void> close() async {
    await _box.close();
  }

  /// Nettoie toutes les données stockées
  static Future<void> clear() async {
    await _box.clear();
  }

  // === Gestion de l'authentification ===

  /// Sauvegarde le token d'authentification
  static Future<void> setToken(String token) async {
    await _box.put(_tokenKey, token);
  }

  /// Récupère le token d'authentification
  static String? getToken() {
    return _box.get(_tokenKey);
  }

  /// Supprime le token d'authentification
  static Future<void> clearToken() async {
    await _box.delete(_tokenKey);
  }

  /// Sauvegarde le refresh token
  static Future<void> setRefreshToken(String refreshToken) async {
    await _box.put(_refreshTokenKey, refreshToken);
  }

  /// Récupère le refresh token
  static String? getRefreshToken() {
    return _box.get(_refreshTokenKey);
  }

  /// Supprime le refresh token
  static Future<void> clearRefreshToken() async {
    await _box.delete(_refreshTokenKey);
  }

  /// Sauvegarde la date d'expiration du token
  static Future<void> setTokenExpiration(DateTime expiration) async {
    await _box.put(_tokenExpirationKey, expiration.toIso8601String());
  }

  /// Récupère la date d'expiration du token
  static DateTime? getTokenExpiration() {
    final expirationString = _box.get(_tokenExpirationKey);
    if (expirationString != null) {
      return DateTime.tryParse(expirationString);
    }
    return null;
  }

  /// Supprime la date d'expiration du token
  static Future<void> clearTokenExpiration() async {
    await _box.delete(_tokenExpirationKey);
  }

  /// Sauvegarde les données utilisateur
  static Future<void> setUser(Map<String, dynamic> userData) async {
    await _box.put(_userKey, userData);
  }

  /// Récupère les données utilisateur
  static Map<String, dynamic>? getUser() {
    final userData = _box.get(_userKey);
    if (userData is Map) {
      return Map<String, dynamic>.from(userData);
    }
    return null;
  }

  /// Supprime les données utilisateur
  static Future<void> clearUser() async {
    await _box.delete(_userKey);
  }

  /// Vérifie si l'utilisateur est connecté (a un token valide)
  static bool isLoggedIn() {
    final token = getToken();
    if (token == null) return false;

    final expiration = getTokenExpiration();
    if (expiration != null && DateTime.now().isAfter(expiration)) {
      return false;
    }

    return true;
  }

  // === Gestion des préférences ===

  /// Sauvegarde le mode de thème
  static Future<void> setThemeMode(String themeMode) async {
    await _box.put(_themeKey, themeMode);
  }

  /// Récupère le mode de thème
  static String? getThemeMode() {
    return _box.get(_themeKey);
  }

  /// Sauvegarde la langue
  static Future<void> setLanguage(String language) async {
    await _box.put(_languageKey, language);
  }

  /// Récupère la langue
  static String? getLanguage() {
    return _box.get(_languageKey);
  }

  /// Marque l'onboarding comme terminé
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _box.put(_onboardingKey, completed);
  }

  /// Vérifie si l'onboarding est terminé
  static bool isOnboardingCompleted() {
    return _box.get(_onboardingKey, defaultValue: false);
  }

  /// Active/désactive l'authentification biométrique
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _box.put(_biometricKey, enabled);
  }

  /// Vérifie si l'authentification biométrique est activée
  static bool isBiometricEnabled() {
    return _box.get(_biometricKey, defaultValue: false);
  }

  /// Active/désactive les notifications
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _box.put(_notificationsKey, enabled);
  }

  /// Vérifie si les notifications sont activées
  static bool areNotificationsEnabled() {
    return _box.get(_notificationsKey, defaultValue: true);
  }

  /// Active/désactive l'analytics
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    await _box.put(_analyticsKey, enabled);
  }

  /// Vérifie si l'analytics est activé
  static bool isAnalyticsEnabled() {
    return _box.get(_analyticsKey, defaultValue: true);
  }

  // === Méthodes utilitaires ===

  /// Sauvegarde une valeur générique
  static Future<void> setValue(String key, dynamic value) async {
    await _box.put(key, value);
  }

  /// Récupère une valeur générique
  static T? getValue<T>(String key, {T? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  /// Supprime une clé
  static Future<void> deleteValue(String key) async {
    await _box.delete(key);
  }

  /// Vérifie si une clé existe
  static bool hasKey(String key) {
    return _box.containsKey(key);
  }

  /// Récupère toutes les clés
  static Iterable<dynamic> getAllKeys() {
    return _box.keys;
  }

  /// Récupère toutes les valeurs
  static Iterable<dynamic> getAllValues() {
    return _box.values;
  }

  /// Récupère la taille du stockage
  static int getStorageSize() {
    return _box.length;
  }

  /// Exporte toutes les données (pour debug/backup)
  static Map<String, dynamic> exportAllData() {
    final Map<String, dynamic> data = {};
    for (final key in _box.keys) {
      data[key.toString()] = _box.get(key);
    }
    return data;
  }

  /// Importe des données (pour restore)
  static Future<void> importData(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await _box.put(entry.key, entry.value);
    }
  }

  // === Cache temporaire ===

  /// Sauvegarde une valeur avec expiration
  static Future<void> setCachedValue(
    String key,
    dynamic value, {
    Duration? expiration,
  }) async {
    final cacheData = {
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
      if (expiration != null) 'expiration': expiration.inMilliseconds,
    };
    await _box.put('cache_$key', cacheData);
  }

  /// Récupère une valeur en cache (si pas expirée)
  static T? getCachedValue<T>(String key) {
    final cacheData = _box.get('cache_$key');
    if (cacheData is! Map) return null;

    final timestamp = DateTime.tryParse(cacheData['timestamp'] ?? '');
    if (timestamp == null) return null;

    final expiration = cacheData['expiration'] as int?;
    if (expiration != null) {
      final expirationTime = timestamp.add(Duration(milliseconds: expiration));
      if (DateTime.now().isAfter(expirationTime)) {
        // Cache expiré, le supprimer
        _box.delete('cache_$key');
        return null;
      }
    }

    return cacheData['value'] as T?;
  }

  /// Supprime une valeur en cache
  static Future<void> clearCachedValue(String key) async {
    await _box.delete('cache_$key');
  }

  /// Nettoie tous les caches expirés
  static Future<void> cleanExpiredCache() async {
    final keysToDelete = <String>[];
    
    for (final key in _box.keys) {
      if (key.toString().startsWith('cache_')) {
        final cacheData = _box.get(key);
        if (cacheData is Map) {
          final timestamp = DateTime.tryParse(cacheData['timestamp'] ?? '');
          final expiration = cacheData['expiration'] as int?;
          
          if (timestamp != null && expiration != null) {
            final expirationTime = timestamp.add(Duration(milliseconds: expiration));
            if (DateTime.now().isAfter(expirationTime)) {
              keysToDelete.add(key.toString());
            }
          }
        }
      }
    }
    
    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }
}