// mobile/lib/features/auth/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/models/auth_models.dart';

class AuthResponse {
  final User user;
  final String token;
  final DateTime? expiresAt;
  final String? refreshToken;

  AuthResponse({
    required this.user,
    required this.token,
    this.expiresAt,
    this.refreshToken,
  });

  factory AuthResponse.fromAuthResponseData(AuthResponseData data) {
    return AuthResponse(
      user: data.user,
      token: data.jwt,
      expiresAt: data.expiresAt,
      refreshToken: data.refreshToken,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get needsRefresh {
    if (expiresAt == null) return false;
    // Rafraîchir si expire dans moins de 5 minutes
    return DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt!);
  }
}

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Vérifier si le token n'est pas expiré
    final expirationData = await getTokenExpiration();
    if (expirationData != null && DateTime.now().isAfter(expirationData)) {
      // Token expiré, essayer de le rafraîchir
      return await tryRefreshToken();
    }
    
    return true;
  }

  /// Récupère le token d'authentification
  Future<String?> getToken() async {
    return StorageService.getToken();
  }

  /// Récupère la date d'expiration du token
  Future<DateTime?> getTokenExpiration() async {
    return StorageService.getTokenExpiration();
  }

  /// Récupère le refresh token
  Future<String?> getRefreshToken() async {
    return StorageService.getRefreshToken();
  }

  /// Récupère l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      return response.data;
    } catch (e) {
      // Si l'API échoue, essayer de récupérer depuis le cache local
      final userData = StorageService.getUser();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    }
  }

  /// Connexion avec email et mot de passe
  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final loginRequest = LoginRequest(
        identifier: email,
        password: password,
        rememberMe: rememberMe,
      );

      final response = await _apiService.login(loginRequest);
      final authData = response.data!;
      
      // Sauvegarder les données d'authentification
      await _saveAuthData(authData);

      return AuthResponse.fromAuthResponseData(authData);
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? company,
    String? position,
    String? phone,
    bool acceptTerms = true,
    bool acceptMarketing = false,
  }) async {
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        company: company,
        position: position,
        phone: phone,
        acceptTerms: acceptTerms,
        acceptMarketing: acceptMarketing,
      );

      final response = await _apiService.register(registerRequest);
      final authData = response.data!;
      
      // Sauvegarder les données d'authentification
      await _saveAuthData(authData);

      return AuthResponse.fromAuthResponseData(authData);
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Demande de réinitialisation de mot de passe
  Future<void> forgotPassword({required String email}) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      await _apiService.forgotPassword(request);
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Réinitialisation du mot de passe avec token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw AuthException('Les mots de passe ne correspondent pas');
    }

    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      await _apiService.resetPassword(request);
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Rafraîchissement du token d'authentification
  Future<bool> tryRefreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiService.refreshToken(request);
      final authData = response.data!;
      
      // Sauvegarder les nouvelles données d'authentification
      await _saveAuthData(authData);
      return true;
    } catch (e) {
      // Échec du rafraîchissement, déconnecter l'utilisateur
      await logout();
      return false;
    }
  }

  /// Vérification de l'email
  Future<void> verifyEmail({required String token}) async {
    try {
      await _apiService.verifyEmail(token);
      
      // Mettre à jour le statut de vérification de l'utilisateur local
      final userData = StorageService.getUser();
      if (userData != null) {
        final user = User.fromJson(userData);
        final updatedUser = user.copyWith(emailVerified: true);
        await StorageService.setUser(updatedUser.toJson());
      }
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Renvoyer l'email de vérification
  Future<void> resendVerificationEmail() async {
    try {
      await _apiService.resendVerificationEmail();
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Changement de mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw AuthException('Les nouveaux mots de passe ne correspondent pas');
    }

    try {
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      // Notifier le serveur de la déconnexion
      await _apiService.logout();
    } catch (e) {
      // Continuer même si l'appel serveur échoue
    } finally {
      // Nettoyer les données locales
      await _clearAuthData();
    }
  }

  /// Suppression du compte
  Future<void> deleteAccount({required String password}) async {
    try {
      await _apiService.deleteAccount(password: password);
      await _clearAuthData();
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Méthodes privées

  /// Sauvegarde les données d'authentification localement
  Future<void> _saveAuthData(AuthResponseData authData) async {
    await StorageService.setToken(authData.jwt);
    await StorageService.setUser(authData.user.toJson());
    
    if (authData.expiresAt != null) {
      await StorageService.setTokenExpiration(authData.expiresAt!);
    }
    
    if (authData.refreshToken != null) {
      await StorageService.setRefreshToken(authData.refreshToken!);
    }
  }

  /// Nettoie toutes les données d'authentification
  Future<void> _clearAuthData() async {
    await StorageService.clearToken();
    await StorageService.clearUser();
    await StorageService.clearTokenExpiration();
    await StorageService.clearRefreshToken();
  }

  /// Gère les erreurs d'authentification
  AuthException _handleAuthError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return AuthException('Données d\'authentification invalides');
      case 401:
        return AuthException('Email ou mot de passe incorrect');
      case 403:
        return AuthException('Accès interdit');
      case 404:
        return AuthException('Utilisateur non trouvé');
      case 409:
        return AuthException('Un compte avec cet email existe déjà');
      case 422:
        return AuthException('Données de validation invalides');
      case 429:
        return AuthException('Trop de tentatives, veuillez réessayer plus tard');
      case 500:
        return AuthException('Erreur serveur, veuillez réessayer');
      default:
        return AuthException('Erreur de connexion: ${e.message}');
    }
  }

  // Méthodes utilitaires

  /// Vérifie si l'utilisateur a vérifié son email
  Future<bool> isEmailVerified() async {
    final user = await getCurrentUser();
    return user?.emailVerified ?? false;
  }

  /// Vérifie si l'utilisateur est administrateur
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  /// Récupère le rôle de l'utilisateur
  Future<UserRole?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
  }

  /// Met à jour le profil utilisateur
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? company,
    String? position,
    String? phoneNumber,
    String? website,
    String? linkedinUrl,
  }) async {
    try {
      final response = await _apiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        company: company,
        position: position,
        phoneNumber: phoneNumber,
        website: website,
        linkedinUrl: linkedinUrl,
      );

      final updatedUser = response.data!;
      await StorageService.setUser(updatedUser.toJson());
      
      return updatedUser;
    } on DioException catch (e) {
      throw _handleAuthError(e);
    }
  }
}

/// Exception personnalisée pour les erreurs d'authentification
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, [this.code]);

  @override
  String toString() => 'AuthException: $message';
}