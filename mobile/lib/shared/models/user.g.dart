// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      isActive: json['isActive'] as bool,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      role: json['role'] as String? ?? 'user',
      emailVerified: json['emailVerified'] as bool? ?? false,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      profile: json['profile'] == null
          ? null
          : Profile.fromJson(json['profile'] as Map<String, dynamic>),
      emailVerificationToken: json['emailVerificationToken'] as String?,
      passwordResetToken: json['passwordResetToken'] as String?,
      passwordResetExpires: json['passwordResetExpires'] == null
          ? null
          : DateTime.parse(json['passwordResetExpires'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'isActive': instance.isActive,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'role': instance.role,
      'emailVerified': instance.emailVerified,
      'timezone': instance.timezone,
      'language': instance.language,
      'profile': instance.profile,
      'emailVerificationToken': instance.emailVerificationToken,
      'passwordResetToken': instance.passwordResetToken,
      'passwordResetExpires': instance.passwordResetExpires?.toIso8601String(),
    };
