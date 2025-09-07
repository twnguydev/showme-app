// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role:
          $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
      emailVerified: json['emailVerified'] as bool? ?? false,
      emailVerificationToken: json['emailVerificationToken'] as String?,
      passwordResetToken: json['passwordResetToken'] as String?,
      passwordResetExpires: json['passwordResetExpires'] == null
          ? null
          : DateTime.parse(json['passwordResetExpires'] as String),
      refreshToken: json['refreshToken'] as String?,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      defaultPhone: json['defaultPhone'] as String?,
      defaultCompany: json['defaultCompany'] as String?,
      defaultPosition: json['defaultPosition'] as String?,
      defaultAvatar: json['defaultAvatar'] == null
          ? null
          : UploadedFile.fromJson(
              json['defaultAvatar'] as Map<String, dynamic>),
      subscription: json['subscription'] == null
          ? null
          : Subscription.fromJson(json['subscription'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'emailVerified': instance.emailVerified,
      'emailVerificationToken': instance.emailVerificationToken,
      'passwordResetToken': instance.passwordResetToken,
      'passwordResetExpires': instance.passwordResetExpires?.toIso8601String(),
      'refreshToken': instance.refreshToken,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'isActive': instance.isActive,
      'defaultPhone': instance.defaultPhone,
      'defaultCompany': instance.defaultCompany,
      'defaultPosition': instance.defaultPosition,
      'defaultAvatar': instance.defaultAvatar,
      'subscription': instance.subscription,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.user: 'user',
  UserRole.admin: 'admin',
  UserRole.moderator: 'moderator',
};
