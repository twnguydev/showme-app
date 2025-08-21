// mobile/lib/features/auth/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    this.refreshToken
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

  late final GoogleSignIn _googleSignIn;

  AuthRepository({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService,
        _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

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
      final userData = await StorageService.getUser();
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
  }

  /// Connexion avec Apple
  Future<AuthResponse> loginWithApple() async {
    try {
      // Vérifier la disponibilité d'Apple Sign In
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw const AuthException('Apple Sign In n\'est pas disponible sur cet appareil');
      }

      // Demander les credentials Apple avec gestion d'erreur améliorée
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.votre.bundle.id', // Remplacez par votre bundle ID
          redirectUri: Uri.parse('http://localhost:3000/api/v1/auth/apple/callback'),
        ),
      );

      // Créer la requête pour votre API
      final loginRequest = SocialLoginRequest(
        provider: 'apple',
        identityToken: credential.identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        firstName: credential.givenName,
        lastName: credential.familyName,
        userIdentifier: credential.userIdentifier,
      );

      // Utiliser votre ApiService existant
      final response = await _apiService.socialLogin(loginRequest);
      final authData = response.data!;
      
      // Sauvegarder avec votre méthode existante
      await _saveAuthData(authData);

      return AuthResponse.fromAuthResponseData(authData);
    } on SignInWithAppleAuthorizationException catch (e) {
      // Gestion spécifique des erreurs Apple
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw const AuthException('Connexion Apple annulée');
        case AuthorizationErrorCode.failed:
          throw const AuthException('Échec de la connexion Apple');
        case AuthorizationErrorCode.invalidResponse:
          throw const AuthException('Réponse Apple invalide');
        case AuthorizationErrorCode.notHandled:
          throw const AuthException('Connexion Apple non gérée');
        case AuthorizationErrorCode.unknown:
        default:
          throw AuthException('Erreur Apple inconnue: ${e.code}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      print('🚨 Apple Login Error: $e');
      throw AuthException('Erreur lors de la connexion Apple: $e');
    }
  }

  /// Connexion avec Google
  Future<AuthResponse> loginWithGoogle() async {
    try {
      // Se connecter avec Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw const AuthException('Connexion Google annulée');
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Vérifier que nous avons les tokens nécessaires
      if (googleAuth.idToken == null) {
        throw const AuthException('Token Google ID manquant');
      }

      // Créer la requête pour votre API
      final loginRequest = SocialLoginRequest(
        provider: 'google',
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
        email: googleUser.email,
        firstName: googleUser.displayName?.split(' ').first,
        lastName: googleUser.displayName?.split(' ').skip(1).join(' '),
        photoUrl: googleUser.photoUrl,
      );

      // Utiliser votre ApiService existant
      final response = await _apiService.socialLogin(loginRequest);
      final authData = response.data!;
      
      // Sauvegarder avec votre méthode existante
      await _saveAuthData(authData);

      return AuthResponse.fromAuthResponseData(authData);
    } on PlatformException catch (e) {
      // Gestion des erreurs spécifiques à Google Sign In
      switch (e.code) {
        case 'sign_in_canceled':
          throw const AuthException('Connexion Google annulée');
        case 'sign_in_failed':
          throw const AuthException('Échec de la connexion Google');
        case 'network_error':
          throw const AuthException('Erreur réseau lors de la connexion Google');
        default:
          throw AuthException('Erreur Google: ${e.message}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      print('🚨 Google Login Error: $e');
      throw AuthException('Erreur lors de la connexion Google: $e');
    }
  }

  /// Demande de réinitialisation de mot de passe
  Future<void> forgotPassword({required String email}) async {
    final request = ForgotPasswordRequest(email: email);
    await _apiService.forgotPassword(request);
  }

  /// Réinitialisation du mot de passe avec token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw const AuthException('Les mots de passe ne correspondent pas');
    }

    final request = ResetPasswordRequest(
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    await _apiService.resetPassword(request);
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
    await _apiService.verifyEmail(token);
    
    // Mettre à jour le statut de vérification de l'utilisateur local
    final userData = await StorageService.getUser();
    if (userData != null) {
      final user = User.fromJson(userData);
      final updatedUser = user.copyWith(emailVerified: true);
      await StorageService.setUser(updatedUser.toJson());
    }
  }

  /// Renvoyer l'email de vérification
  Future<void> resendVerificationEmail() async {
    await _apiService.resendVerificationEmail();
  }

  /// Changement de mot de passe
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw const AuthException('Les nouveaux mots de passe ne correspondent pas');
    }

    await _apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      // Notifier le serveur de la déconnexion
      await _apiService.logout();
    } catch (e) {
      // Continuer même si l'appel serveur échoue
    } finally {
      // Déconnexion des services sociaux
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignorer les erreurs de déconnexion Google
      }
      
      // Nettoyer les données locales avec votre méthode existante
      await _clearAuthData();
    }
  }

  /// Suppression du compte
  Future<void> deleteAccount({required String password}) async {
    await _apiService.deleteAccount(password: password);
    await _clearAuthData();
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
  Future<String?> getUserRole() async {
    final user = await getCurrentUser();
    return user?.role;
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

class SocialLoginRequest {
  final String provider;
  final String? identityToken;
  final String? authorizationCode;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final String? userIdentifier;

  SocialLoginRequest({
    required this.provider,
    this.identityToken,
    this.authorizationCode,
    this.idToken,
    this.accessToken,
    this.email,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.userIdentifier,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      if (identityToken != null) 'identityToken': identityToken,
      if (authorizationCode != null) 'authorizationCode': authorizationCode,
      if (idToken != null) 'idToken': idToken,
      if (accessToken != null) 'accessToken': accessToken,
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (userIdentifier != null) 'userIdentifier': userIdentifier,
    };
  }
}