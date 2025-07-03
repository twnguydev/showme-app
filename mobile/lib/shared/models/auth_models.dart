// mobile/lib/shared/models/auth_models.dart
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class AuthResponseData {
  final String jwt;
  final User user;
  final DateTime? expiresAt;
  final String? refreshToken;

  const AuthResponseData({
    required this.jwt,
    required this.user,
    this.expiresAt,
    this.refreshToken,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) => _$AuthResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseDataToJson(this);

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get needsRefresh {
    if (expiresAt == null) return false;
    // Rafraîchir si expire dans moins de 5 minutes
    return DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt!);
  }

  AuthResponseData copyWith({
    String? jwt,
    User? user,
    DateTime? expiresAt,
    String? refreshToken,
  }) {
    return AuthResponseData(
      jwt: jwt ?? this.jwt,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

@JsonSerializable()
class LoginRequest {
  final String identifier; // Email ou nom d'utilisateur
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.identifier,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  LoginRequest copyWith({
    String? identifier,
    String? password,
    bool? rememberMe,
  }) {
    return LoginRequest(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? company;
  final String? position;
  final String? phone;
  final bool acceptTerms;
  final bool acceptMarketing;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.company,
    this.position,
    this.phone,
    required this.acceptTerms,
    this.acceptMarketing = false,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  String get fullName => '$firstName $lastName'.trim();

  RegisterRequest copyWith({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? company,
    String? position,
    String? phone,
    bool? acceptTerms,
    bool? acceptMarketing,
  }) {
    return RegisterRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      acceptMarketing: acceptMarketing ?? this.acceptMarketing,
    );
  }
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) => _$ForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);

  bool get passwordsMatch => newPassword == confirmPassword;
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}