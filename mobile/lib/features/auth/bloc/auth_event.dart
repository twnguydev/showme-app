// mobile/lib/features/auth/bloc/auth_event.dart
import 'package:equatable/equatable.dart';
import '../../../shared/models/user.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

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

  @override
  List<Object?> get props => [email, password, firstName, lastName, company, position];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserUpdated extends AuthEvent {
  final User user;

  AuthUserUpdated(this.user);

  @override
  List<Object> get props => [user];
}