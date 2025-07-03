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
    } on DioException catch (e) {
      String message = 'Erreur de connexion';
      
      if (e.response?.statusCode == 400) {
        message = 'Email ou mot de passe incorrect';
      } else if (e.response?.statusCode == 429) {
        message = 'Trop de tentatives, veuillez réessayer plus tard';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Connexion impossible au serveur';
      }
      
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError('Une erreur inattendue s\'est produite'));
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
    } on DioException catch (e) {
      String message = 'Erreur lors de l\'inscription';
      
      if (e.response?.statusCode == 400) {
        final error = e.response?.data;
        if (error?.toString().contains('email') == true) {
          message = 'Cette adresse email est déjà utilisée';
        } else if (error?.toString().contains('password') == true) {
          message = 'Le mot de passe doit contenir au moins 6 caractères';
        }
      }
      
      emit(AuthError(message));
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
}