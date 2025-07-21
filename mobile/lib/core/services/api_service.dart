// mobile/lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:showme/shared/models/profile.dart';
import 'package:showme/shared/models/uploaded_file.dart';

import '../config/app_config.dart';
import '../models/api_response.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/user.dart';
import '../../shared/models/card.dart';
import '../../shared/models/contact_exchange.dart';
import '../../shared/models/contact_stats.dart';
import '../../shared/models/auth_models.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

class ApiService {
  late final Dio _dio;
  
  // Mode développement - utiliser les démos ou le vrai backend
  static const bool USE_REAL_BACKEND = kDebugMode; // Changez à true pour utiliser le backend
  static const String BACKEND_URL = kDebugMode 
    ? 'http://localhost:3000/api/v1'  // URL locale pour développement
    : 'https://votre-backend.com/api'; // URL production

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
        onError: (error, handler) {
          if (kDebugMode && USE_REAL_BACKEND) {
            print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
            print('📄 Error data: ${error.response?.data}');
          }
          
          // Gestion globale des erreurs
          if (error.response?.statusCode == 401) {
            // Token expiré, rediriger vers la connexion
            StorageService.clearToken();
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

  void dispose() {
    // Annuler les requêtes en cours si nécessaire
    _dio.close(force: true);
  }

  // Auth endpoints
  Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    if (!USE_REAL_BACKEND) {
      return _demoLogin(request);
    }

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
    if (!USE_REAL_BACKEND) {
      return _demoRegister(request);
    }

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
    if (!USE_REAL_BACKEND) {
      return _demoSocialLogin(request);
    }

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
    if (!USE_REAL_BACKEND) {
      return _demoGetCurrentUser();
    }

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
    if (!USE_REAL_BACKEND) {
      return _demoRefreshToken(request);
    }

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
    if (!USE_REAL_BACKEND) {
      return _demoLogout();
    }

    try {
      await _dio.post('/auth/logout');
      return ApiResponse<void>.success(message: 'Déconnexion réussie');
    } on DioException catch (e) {
      // Même si l'appel échoue, on considère la déconnexion comme réussie
      return ApiResponse<void>.success(message: 'Déconnexion réussie');
    }
  }

  // Méthodes démo (existantes)
  Future<ApiResponse<AuthResponseData>> _demoLogin(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (request.identifier == 'demo@showme.com' && request.password == 'password') {
      final user = User(
        id: 1,
        username: request.identifier,
        email: request.identifier,
        firstName: 'Tanguy',
        lastName: 'Gbt',
        company: 'Showme Corp',
        position: 'Consultant Senior',
        phoneNumber: '+33 6 12 34 56 78',
        linkedinUrl: 'https://linkedin.com/in/exemple',
        website: 'https://exemple.com',
        profilePicture: null,
        isActive: true,
        lastLoginAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        profile: Profile.demo(),
      );
      
      final authData = AuthResponseData(
        jwt: 'demo_jwt_token_123',
        user: user,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        refreshToken: 'demo_refresh_token_123',
      );
      
      return ApiResponse<AuthResponseData>(data: authData);
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
          data: {'message': 'Identifiants invalides'},
        ),
      );
    }
  }

  Future<ApiResponse<AuthResponseData>> _demoRegister(RegisterRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch,
      username: request.email,
      email: request.email,
      firstName: request.firstName,
      lastName: request.lastName,
      company: request.company,
      position: request.position,
      phoneNumber: null,
      linkedinUrl: null,
      website: null,
      profilePicture: null,
      isActive: true,
      lastLoginAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profile: Profile.demo()
    );
    
    final authData = AuthResponseData(
      jwt: 'demo_jwt_token_456',
      user: user,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      refreshToken: 'demo_refresh_token_456',
    );
    
    return ApiResponse<AuthResponseData>(data: authData);
  }

  Future<ApiResponse<AuthResponseData>> _demoSocialLogin(SocialLoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch,
      username: request.email ?? 'user@${request.provider}.com',
      email: request.email ?? 'user@${request.provider}.com',
      firstName: request.firstName ?? 'Utilisateur',
      lastName: request.lastName ?? request.provider.toUpperCase(),
      company: null,
      position: null,
      phoneNumber: null,
      linkedinUrl: null,
      website: null,
      profilePicture: UploadedFile(url: request.photoUrl ?? 'https://example.com/default.jpg'),
      isActive: true,
      lastLoginAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profile: Profile.demo(),
    );
    
    final authData = AuthResponseData(
      jwt: 'demo_${request.provider}_token_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      refreshToken: 'demo_${request.provider}_refresh_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    return ApiResponse<AuthResponseData>(data: authData);
  }

  Future<ApiResponse<User>> _demoGetCurrentUser() async {
    // Simulation - récupérer depuis le storage local
    final userData = await StorageService.getUser();
    if (userData != null) {
      return ApiResponse<User>(data: User.fromJson(userData));
    }
    
    throw DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 401,
        data: {'message': 'Utilisateur non authentifié'},
      ),
    );
  }

  Future<ApiResponse<AuthResponseData>> _demoRefreshToken(RefreshTokenRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulation - générer un nouveau token
    final user = User.demo();
    final authData = AuthResponseData(
      jwt: 'refreshed_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      refreshToken: 'new_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    return ApiResponse<AuthResponseData>(data: authData);
  }

  Future<ApiResponse<void>> _demoLogout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse<void>.success(message: 'Déconnexion réussie');
  }

  // Business Cards endpoints (gardés en démo pour l'instant)
  Future<ApiResponse<List<Card>>> getBusinessCards() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse<List<Card>>(data: [Card.demo()]);
  }

  Future<ApiResponse<Card>> getBusinessCard(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse<Card>(data: Card.demo());
  }

  Future<ApiResponse<Card>> getPublicBusinessCard(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse<Card>(data: Card.demo());
  }

  Future<ApiResponse<Card>> createBusinessCard(Map<String, dynamic> request) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse<Card>(data: Card.demo());
  }

  Future<ApiResponse<Card>> updateBusinessCard(String id, Map<String, dynamic> request) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse<Card>(data: Card.demo());
  }

  Future<void> deleteBusinessCard(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Response> generateWalletPass(String id) async {
    await Future.delayed(const Duration(seconds: 2));
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
    );
  }

  Future<ApiResponse<List<ContactExchange>>> getContactExchanges() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse<List<ContactExchange>>(data: []);
  }

  Future<ApiResponse<ContactExchange>> createContactExchange(Map<String, dynamic> request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final exchange = ContactExchange(
      id: DateTime.now().millisecondsSinceEpoch,
      timestamp: DateTime.now(),
      geoLocation: request['location'],
      userAgent: request['userAgent'],
      referrer: ExchangeMethod.values.firstWhere(
        (e) => e.toString().split('.').last == (request['method'] ?? 'link').toLowerCase(),
        orElse: () => ExchangeMethod.link,
      ),
      openedOnWallet: false,
      contactAdded: false,
      emailSubmitted: request['receiverEmail'],
      deviceType: DeviceType.unknown,
      card: Card.demo(),
      visitor: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return ApiResponse<ContactExchange>(data: exchange);
  }

  Future<ApiResponse<ContactStats>> getContactStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final stats = ContactStats.demo();
    return ApiResponse<ContactStats>(data: stats);
  }

  // Méthodes d'authentification additionnelles
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
    if (!USE_REAL_BACKEND) {
      return _demoChangePassword(currentPassword, newPassword);
    }

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
    if (!USE_REAL_BACKEND) {
      return _demoUpdateProfile(updateData);
    }

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
    if (!USE_REAL_BACKEND) {
      return _demoUpdateDetailedProfile(updateData);
    }

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

  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(File imageFile) async {
    if (!USE_REAL_BACKEND) {
      return _demoUploadAvatar(imageFile);
    }

    try {
      // Créer FormData pour l'upload multipart
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.put(
        '/users/me/avatar',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return ApiResponse<Map<String, dynamic>>(
        data: response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> _demoUploadAvatar(File imageFile) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simuler un upload réussi avec une URL d'image de démo
    const demoUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face';
    
    return ApiResponse<Map<String, dynamic>>(
      data: {
        'url': demoUrl,
        'filename': imageFile.path.split('/').last,
        'size': await imageFile.length(),
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<ApiResponse<User>> _demoUpdateProfile(Map<String, dynamic> updateData) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Récupérer l'utilisateur actuel depuis le storage
    final userData = StorageService.getUser();
    if (userData == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
          data: {'message': 'Utilisateur non authentifié'},
        ),
      );
    }
    
    // Créer un utilisateur mis à jour avec les nouvelles données
    final currentUser = User.fromJson(userData);
    final updatedUser = currentUser.copyWith(
      firstName: updateData['firstName'],
      lastName: updateData['lastName'],
      email: updateData['email'],
      phoneNumber: updateData['phoneNumber'],
      company: updateData['company'],
      position: updateData['position'],
      website: updateData['website'],
      linkedinUrl: updateData['linkedinUrl'],
    );
    
    // Sauvegarder les données mises à jour
    await StorageService.setUser(updatedUser.toJson());
    
    return ApiResponse<User>(data: updatedUser);
  }

  Future<ApiResponse<dynamic>> _demoUpdateDetailedProfile(Map<String, dynamic> updateData) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return ApiResponse<dynamic>(
      data: {
        'message': 'Profil détaillé mis à jour avec succès',
        'profile': updateData,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<ApiResponse<void>> _demoChangePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simuler la vérification du mot de passe actuel
    if (currentPassword == 'password') {
      return ApiResponse<void>.success(
        message: 'Mot de passe modifié avec succès',
      );
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Mot de passe actuel incorrect'},
        ),
      );
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
        errorMessage = data['message'] ?? 
                     data['error'] ?? 
                     data['details'] ?? 
                     'Erreur serveur';
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
        return AuthException('Trop de tentatives, veuillez réessayer plus tard');
      case 500:
        return AuthException('Erreur serveur');
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          return AuthException('Timeout de connexion - vérifiez votre connexion');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          return AuthException('Timeout de réception');
        } else if (e.type == DioExceptionType.connectionError) {
          return AuthException('Erreur de connexion réseau - vérifiez votre connexion');
        }
        return AuthException(errorMessage.isNotEmpty ? errorMessage : 'Erreur réseau: ${e.message}');
    }
  }
}