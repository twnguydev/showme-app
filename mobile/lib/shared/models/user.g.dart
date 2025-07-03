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
      company: json['company'] as String?,
      position: json['position'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      website: json['website'] as String?,
      profilePicture: json['profilePicture'] == null
          ? null
          : UploadedFile.fromJson(
              json['profilePicture'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      role:
          $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
      emailVerified: json['emailVerified'] as bool? ?? false,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'company': instance.company,
      'position': instance.position,
      'phoneNumber': instance.phoneNumber,
      'linkedinUrl': instance.linkedinUrl,
      'website': instance.website,
      'profilePicture': instance.profilePicture,
      'isActive': instance.isActive,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'role': _$UserRoleEnumMap[instance.role]!,
      'emailVerified': instance.emailVerified,
      'timezone': instance.timezone,
      'language': instance.language,
    };

const _$UserRoleEnumMap = {
  UserRole.user: 'user',
  UserRole.moderator: 'moderator',
  UserRole.admin: 'admin',
};
