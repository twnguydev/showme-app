// mobile/lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../../core/services/storage_service.dart';

class ApiService {
  late final Dio _dio;
  
  // Callback pour gérer la déconnexion automatique
  static void Function()? _onUnauthorized;
  
  // Mode développement - utiliser les démos ou le vrai backend
  // ignore: constant_identifier_names
  static const bool USE_REAL_BACKEND = kDebugMode;
  // ignore: constant_identifier_names
  static const String BACKEND_URL = kDebugMode 
    ? 'http://localhost:3000/api/v1'
    : 'https://votre-backend.com/api';

  // Méthode statique pour configurer le callback de déconnexion
  static void setUnauthorizedCallback(void Function() callback) {
    _onUnauthorized = callback;
  }

  ApiService() {
    _dio = Dio();
    
    // Configuration de base
    _dio.options.baseUrl = USE_REAL_BACKEND ? BACKEND_URL : AppConfig.apiUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le token d'authentification
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          if (kDebugMode && USE_REAL_BACKEND) {
            print('🚀 API Request: ${options.method} ${options.path}');
            print('📋 Headers: ${options.headers}');
            if (options.data != null) {
              print('📦 Data: ${options.data}');
            }
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode && USE_REAL_BACKEND) {
            print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode && USE_REAL_BACKEND) {
            print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
            print('📄 Error data: ${error.response?.data}');
          }
          
          // Gestion globale des erreurs 401
          if (error.response?.statusCode == 401) {
            print('🔐 Token expiré ou invalide - Déconnexion automatique');
            
            // Nettoyer les données d'authentification
            await _handleUnauthorized();
            
            // Déclencher la déconnexion via le callback
            if (_onUnauthorized != null) {
              _onUnauthorized!();
            }
          }
          
          handler.next(error);
        },
      ),
    );

    // Logs pour debugging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ));
    }
  }

  // Méthode privée pour nettoyer les données d'authentification
  Future<void> _handleUnauthorized() async {
    try {
      await StorageService.clearToken();
      await StorageService.clearUser();
      print('🧹 Données d\'authentification nettoyées');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }

  void dispose() {
    _dio.close(force: true);
  }

  // Getter pour accéder au Dio depuis les services spécialisés
  Dio get dio => _dio;
}