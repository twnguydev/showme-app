// mobile/lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:showme/shared/models/card.dart';

import '../config/app_config.dart';
import '../models/api_response.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/user.dart';
import '../../shared/models/auth_models.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

class ApiService {
  late final Dio _dio;
  
  // Callback pour gérer la déconnexion automatique
  static void Function()? _onUnauthorized;
  
  // Mode développement - utiliser les démos ou le vrai backend
  static const bool USE_REAL_BACKEND = kDebugMode;
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

  // Auth endpoints
  Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'identifier': request.identifier,
          'password': request.password,
          'rememberMe': request.rememberMe,
        },
      );

      return ApiResponse<AuthResponseData>(
        data: AuthResponseData.fromJson(response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<AuthResponseData>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': request.email,
          'password': request.password,
          'firstName': request.firstName,
          'lastName': request.lastName,
          'company': request.company,
          'position': request.position,
          'phone': request.phone,
          'acceptTerms': request.acceptTerms,
          'acceptMarketing': request.acceptMarketing,
        },
      );

      return ApiResponse<AuthResponseData>(
        data: AuthResponseData.fromJson(response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<AuthResponseData>> socialLogin(SocialLoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/social-login',
        data: request.toJson(),
      );

      return ApiResponse<AuthResponseData>(
        data: AuthResponseData.fromJson(response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      
      return ApiResponse<User>(
        data: User.fromJson(response.data['user']),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<AuthResponseData>> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': request.refreshToken},
      );

      return ApiResponse<AuthResponseData>(
        data: AuthResponseData.fromJson(response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
      return ApiResponse<void>.success(message: 'Déconnexion réussie');
    } on DioException {
      // Même si l'appel échoue, on considère la déconnexion comme réussie
      return ApiResponse<void>.success(message: 'Déconnexion réussie');
    }
  }

  // Méthodes pour upload d'avatar
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(File imageFile) async {
    try {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      print('Uploading file with MIME type: $mimeType');
      
      if (!mimeType.startsWith('image/')) {
        throw Exception('Le fichier sélectionné n\'est pas une image valide');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      });

      print('Uploading file: ${imageFile.path}');
      print('File size: ${await imageFile.length()} bytes');

      final response = await _dio.put(
        '/users/me/avatar',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('Upload response: ${response.data}');

      return ApiResponse<Map<String, dynamic>>(
        data: response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      print('Upload error: ${e.message}');
      print('Upload error response: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      print('Upload error (general): $e');
      throw Exception('Erreur lors de l\'upload de l\'avatar: $e');
    }
  }

    Future<ApiResponse<AuthResponseData>> forgotPassword(ForgotPasswordRequest request) async {
    if (!USE_REAL_BACKEND) {
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse<AuthResponseData>.success(
        message: 'Email de réinitialisation envoyé',
      );
    }

    try {
      await _dio.post('/auth/forgot-password', data: request.toJson());
      return ApiResponse<AuthResponseData>.success(
        message: 'Email de réinitialisation envoyé',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<AuthResponseData>> resetPassword(ResetPasswordRequest request) async {
    if (!USE_REAL_BACKEND) {
      await Future.delayed(const Duration(seconds: 1));
      if (request.passwordsMatch) {
        return ApiResponse<AuthResponseData>.success(
          message: 'Mot de passe réinitialisé avec succès',
        );
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
            data: {'message': 'Les mots de passe ne correspondent pas'},
          ),
        );
      }
    }

    try {
      await _dio.post('/auth/reset-password', data: request.toJson());
      return ApiResponse<AuthResponseData>.success(
        message: 'Mot de passe réinitialisé avec succès',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<void>> verifyEmail(String token) async {
    if (!USE_REAL_BACKEND) {
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse<void>.success(message: 'Email vérifié avec succès');
    }

    try {
      await _dio.post('/auth/verify-email', data: {'token': token});
      return ApiResponse<void>.success(message: 'Email vérifié avec succès');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<void>> resendVerificationEmail() async {
    if (!USE_REAL_BACKEND) {
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse<void>.success(message: 'Email de vérification renvoyé');
    }

    try {
      await _dio.post('/auth/resend-verification');
      return ApiResponse<void>.success(message: 'Email de vérification renvoyé');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/users/me/password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      return ApiResponse<void>.success(
        message: 'Mot de passe modifié avec succès',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<void>> deleteAccount({required String password}) async {
    if (!USE_REAL_BACKEND) {
      await Future.delayed(const Duration(seconds: 2));
      return ApiResponse<void>.success(message: 'Compte supprimé avec succès');
    }

    try {
      await _dio.delete('/auth/account', data: {'password': password});
      return ApiResponse<void>.success(message: 'Compte supprimé avec succès');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put(
        '/users/me',
        data: updateData,
      );

      return ApiResponse<User>(
        data: User.fromJson(response.data['user'] ?? response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Mise à jour du profil détaillé
  Future<ApiResponse<dynamic>> updateDetailedProfile(Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put(
        '/users/me/profile',
        data: updateData,
      );

      return ApiResponse<dynamic>(
        data: response.data,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Gestion des erreurs DioException améliorée
  Exception _handleDioException(DioException e) {
    print('🚨 DioException: ${e.toString()}');
    print('🚨 Response: ${e.response?.data}');
    
    // Essayer d'extraire le message d'erreur du backend
    String errorMessage = 'Erreur inconnue';
    
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        // Gérer le cas où message est une List
        if (data.containsKey('message')) {
          final message = data['message'];
          if (message is List && message.isNotEmpty) {
            errorMessage = message.first.toString();
          } else if (message is String && message.isNotEmpty) {
            errorMessage = message;
          }
        } 
        // Si pas de message ou message vide, essayer error
        else if (data.containsKey('error') && data['error'] is String) {
          errorMessage = data['error'];
        }
        // Si pas d'error, essayer details
        else if (data.containsKey('details') && data['details'] is String) {
          errorMessage = data['details'];
        }
        // Sinon, message par défaut
        else {
          errorMessage = 'Erreur serveur';
        }
      } else if (data is String) {
        errorMessage = data;
      }
    }

    switch (e.response?.statusCode) {
      case 400:
        return AuthException(errorMessage.isEmpty ? 'Données invalides' : errorMessage);
      case 401:
        return AuthException(errorMessage.isEmpty ? 'Non autorisé' : errorMessage);
      case 403:
        return AuthException(errorMessage.isEmpty ? 'Accès interdit' : errorMessage);
      case 404:
        return AuthException(errorMessage.isEmpty ? 'Ressource non trouvée' : errorMessage);
      case 409:
        return AuthException(errorMessage.isEmpty ? 'Conflit - ressource déjà existante' : errorMessage);
      case 422:
        return AuthException(errorMessage.isEmpty ? 'Données de validation invalides' : errorMessage);
      case 429:
        return const AuthException('Trop de tentatives, veuillez réessayer plus tard');
      case 500:
        return const AuthException('Erreur serveur');
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          return const AuthException('Timeout de connexion - vérifiez votre connexion');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          return const AuthException('Timeout de réception');
        } else if (e.type == DioExceptionType.connectionError) {
          return const AuthException('Erreur de connexion réseau - vérifiez votre connexion');
        }
        return AuthException(errorMessage.isNotEmpty ? errorMessage : 'Erreur réseau: ${e.message}');
    }
  }

  Future<ApiResponse<List<Card>>> getBusinessCards() async {
    try {
      final response = await _dio.get('/cards');
      
      final List<dynamic> cardsData = response.data['data'] ?? response.data;
      final cards = cardsData.map((cardJson) => Card.fromJson(cardJson)).toList();
      
      return ApiResponse<List<Card>>(data: cards);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<Card>> getBusinessCard(String id) async {
    try {
      final response = await _dio.get('/cards/$id');
      
      return ApiResponse<Card>(
        data: Card.fromJson(response.data['data'] ?? response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<Card>> getPublicBusinessCard(String id) async {
    try {
      final response = await _dio.get('/public/cards/$id');
      
      return ApiResponse<Card>(
        data: Card.fromJson(response.data['data'] ?? response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<Card>> createBusinessCard(Map<String, dynamic> cardData) async {
    try {
      final response = await _dio.post('/cards', data: cardData);
      
      return ApiResponse<Card>(
        data: Card.fromJson(response.data['data'] ?? response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<Card>> updateBusinessCard(String id, Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put('/cards/$id', data: updateData);
      
      return ApiResponse<Card>(
        data: Card.fromJson(response.data['data'] ?? response.data),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteBusinessCard(String id) async {
    try {
      await _dio.delete('/cards/$id');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadCardImage(
    String cardId,
    File imageFile,
    String imageType,
  ) async {
    try {
      // Déterminer le type MIME du fichier
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      
      if (!mimeType.startsWith('image/')) {
        throw Exception('Le fichier sélectionné n\'est pas une image valide');
      }

      // Créer FormData pour l'upload multipart
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
        'type': imageType, // 'avatar', 'logo', 'background'
      });

      final response = await _dio.post(
        '/cards/$cardId/upload-image',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      return ApiResponse<Map<String, dynamic>>(
        data: response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> generateWalletPass(String id) async {
    try {
      return await _dio.get(
        '/cards/$id/wallet-pass',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/vnd.apple.pkpass',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
}