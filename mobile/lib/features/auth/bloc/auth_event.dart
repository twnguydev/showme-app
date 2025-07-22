// mobile/lib/features/auth/bloc/auth_event.dart
import '../../../shared/models/user.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({
    required this.email,
    required this.password,
  });
}

class AuthAppleLoginRequested extends AuthEvent {}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? company;
  final String? position;

  AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.company,
    this.position,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserUpdated extends AuthEvent {
  final User user;

  AuthUserUpdated({required this.user});
}

// Nouvel event pour gérer l'expiration automatique du token
class AuthTokenExpired extends AuthEvent {}

// Event optionnel pour forcer la vérification du token
class AuthTokenValidationRequested extends AuthEvent {}