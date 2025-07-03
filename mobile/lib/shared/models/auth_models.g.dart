// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseData _$AuthResponseDataFromJson(Map<String, dynamic> json) =>
    AuthResponseData(
      jwt: json['jwt'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$AuthResponseDataToJson(AuthResponseData instance) =>
    <String, dynamic>{
      'jwt': instance.jwt,
      'user': instance.user,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'refreshToken': instance.refreshToken,
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      identifier: json['identifier'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'password': instance.password,
      'rememberMe': instance.rememberMe,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      company: json['company'] as String?,
      position: json['position'] as String?,
      phone: json['phone'] as String?,
      acceptTerms: json['acceptTerms'] as bool,
      acceptMarketing: json['acceptMarketing'] as bool? ?? false,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'company': instance.company,
      'position': instance.position,
      'phone': instance.phone,
      'acceptTerms': instance.acceptTerms,
      'acceptMarketing': instance.acceptMarketing,
    };

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordRequest(
      email: json['email'] as String,
    );

Map<String, dynamic> _$ForgotPasswordRequestToJson(
        ForgotPasswordRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

ResetPasswordRequest _$ResetPasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ResetPasswordRequest(
      token: json['token'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );

Map<String, dynamic> _$ResetPasswordRequestToJson(
        ResetPasswordRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
      'newPassword': instance.newPassword,
      'confirmPassword': instance.confirmPassword,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestToJson(
        RefreshTokenRequest instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };
