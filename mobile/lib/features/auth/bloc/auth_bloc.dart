// mobile/lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../data/repositories/auth_repository.dart';

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
      emit(AuthError('Une erreur inattendue s\'est produite : $e'));
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

  /// Gère les erreurs DioException de manière centralisée
  String _handleDioError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return 'Données d\'authentification invalides';
      case 401:
        return 'Email ou mot de passe incorrect';
      case 403:
        return 'Accès interdit';
      case 404:
        return 'Utilisateur non trouvé';
      case 409:
        return 'Un compte avec cet email existe déjà';
      case 422:
        return 'Données de validation invalides';
      case 429:
        return 'Trop de tentatives, veuillez réessayer plus tard';
      case 500:
        return 'Erreur serveur, veuillez réessayer';
      default:
        return 'Erreur de connexion: ${e.message}';
    }
  }
}