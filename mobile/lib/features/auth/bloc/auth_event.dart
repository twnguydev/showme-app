// mobile/lib/features/auth/bloc/auth_event.dart
import 'dart:io';
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
  final bool rememberMe;

  AuthLoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [email, password, rememberMe];
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

  @override
  List<Object?> get props => [email, password, firstName, lastName, company, position];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserUpdated extends AuthEvent {
  final User user;

  AuthUserUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthTokenExpired extends AuthEvent {}

class AuthRefreshUserRequested extends AuthEvent {}

class AuthAvatarUploadRequested extends AuthEvent {
  final File imageFile;

  AuthAvatarUploadRequested({required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}