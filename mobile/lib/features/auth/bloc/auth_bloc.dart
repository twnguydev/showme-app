// mobile/lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/services/api_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthAppleLoginRequested>(_onAuthAppleLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);
    on<AuthTokenExpired>(_onAuthTokenExpired);
    on<AuthRefreshUserRequested>(_onAuthRefreshUserRequested);
    on<AuthAvatarUploadRequested>(_onAuthAvatarUploadRequested);

    // Configurer le callback pour la déconnexion automatique
    ApiService.setUnauthorizedCallback(() {
      add(AuthTokenExpired());
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        final token = await _authRepository.getToken();
        
        if (user != null && token != null) {
          emit(AuthAuthenticated(user: user, token: token));
        } else {
          await _authRepository.logout();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      emit(AuthAuthenticated(
        user: result.user,
        token: result.token,
      ));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } on DioException catch (e) {
      emit(AuthError(_handleDioError(e)));
    } catch (e) {
      emit(AuthError('Une erreur inattendue s\'est produite'));
    }
  }

  Future<void> _onAuthAppleLoginRequested(
    AuthAppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.loginWithApple();

      emit(AuthAuthenticated(
        user: result.user,
        token: result.token,
      ));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } on DioException catch (e) {
      emit(AuthError(_handleDioError(e)));
    } catch (e) {
      emit(AuthError('Connexion Apple annulée ou échouée'));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.loginWithGoogle();

      emit(AuthAuthenticated(
        user: result.user,
        token: result.token,
      ));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } on DioException catch (e) {
      emit(AuthError(_handleDioError(e)));
    } catch (e) {
      emit(AuthError('Connexion Google annulée ou échouée'));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        company: event.company,
        position: event.position,
      );

      emit(AuthAuthenticated(
        user: result.user,
        token: result.token,
      ));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } on DioException catch (e) {
      emit(AuthError(_handleDioError(e)));
    } catch (e) {
      print('Exception non gérée: ${e.runtimeType} - $e');
      emit(AuthError('Une erreur inattendue s\'est produite'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      emit(AuthAuthenticated(
        user: event.user,
        token: currentState.token,
      ));
    }
  }

  Future<void> _onAuthTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 Token expiré - Déconnexion automatique');
    
    // Nettoyer les données d'authentification
    await _authRepository.logout();
    
    // Émettre l'état non authentifié
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthRefreshUserRequested(
    AuthRefreshUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      try {
        final user = await _authRepository.refreshCurrentUser();
        
        if (user != null) {
          final currentState = state as AuthAuthenticated;
          emit(AuthAuthenticated(
            user: user,
            token: currentState.token,
          ));
        }
      } catch (e) {
        // En cas d'erreur, on garde l'état actuel
        print('Erreur lors du rafraîchissement de l\'utilisateur: $e');
      }
    }
  }

  Future<void> _onAuthAvatarUploadRequested(
    AuthAvatarUploadRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      
      try {
        // Émettre un état de chargement partiel pour l'avatar
        emit(AuthAvatarUploading(
          user: currentState.user,
          token: currentState.token,
        ));

        // Upload de l'avatar avec rafraîchissement automatique de l'utilisateur
        final updatedUser = await _authRepository.uploadAvatar(event.imageFile);

        // Émettre le nouvel état avec l'utilisateur mis à jour
        emit(AuthAuthenticated(
          user: updatedUser,
          token: currentState.token,
        ));
      } on AuthException catch (e) {
        // En cas d'erreur, revenir à l'état précédent et émettre une erreur
        emit(AuthAuthenticated(
          user: currentState.user,
          token: currentState.token,
        ));
        emit(AuthError(e.message));
      } on DioException catch (e) {
        emit(AuthAuthenticated(
          user: currentState.user,
          token: currentState.token,
        ));
        emit(AuthError(_handleDioError(e)));
      } catch (e) {
        emit(AuthAuthenticated(
          user: currentState.user,
          token: currentState.token,
        ));
        emit(AuthError('Erreur lors de l\'upload de l\'avatar'));
      }
    }
  }

  /// Gère les erreurs DioException de manière centralisée
  String _handleDioError(DioException e) {
    print('🚨 Response: ${e.response?.data}');
    
    if (e.response?.data != null) {
      final data = e.response!.data;
      
      // Gérer les messages d'erreur du backend NestJS
      if (data is Map<String, dynamic>) {
        // Si le message est un tableau (erreurs de validation)
        if (data.containsKey('message') && data['message'] is List) {
          final messages = data['message'] as List;
          return messages.isNotEmpty 
            ? messages.first.toString() 
            : 'Erreur de validation';
        }
        
        // Si le message est une chaîne simple
        if (data.containsKey('message') && data['message'] is String) {
          return data['message'] as String;
        }
        
        // Si on a un champ error
        if (data.containsKey('error') && data['error'] is String) {
          return data['error'] as String;
        }
      }
    }

    // Messages d'erreur par défaut selon le code de statut
    switch (e.response?.statusCode) {
      case 400:
        return 'Données invalides';
      case 401:
        return 'Email ou mot de passe incorrect';
      case 403:
        return 'Accès refusé';
      case 404:
        return 'Service non trouvé';
      case 409:
        return 'Un compte avec cet email existe déjà';
      case 422:
        return 'Données de validation incorrectes';
      case 500:
        return 'Erreur serveur, veuillez réessayer';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return 'Connexion lente, veuillez réessayer';
        } else if (e.type == DioExceptionType.connectionError) {
          return 'Problème de connexion internet';
        }
        return 'Une erreur s\'est produite';
    }
  }
}