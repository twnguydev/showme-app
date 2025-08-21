// mobile/lib/features/auth/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../shared/models/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;

  AuthAuthenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object> get props => [user, token];
}

class AuthAvatarUploading extends AuthState {
  final User user;
  final String token;

  AuthAvatarUploading({
    required this.user,
    required this.token,
  });

  @override
  List<Object> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(dynamic rawMessage) : message = _convertToString(rawMessage);

  static String _convertToString(dynamic value) {
    if (value is String) return value;
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is Map && value.containsKey('message')) {
      return _convertToString(value['message']);
    }
    return 'Une erreur inattendue s\'est produite';
  }

  @override
  List<Object> get props => [message];
}