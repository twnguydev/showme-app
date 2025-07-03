// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      position: json['position'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      twitterUrl: json['twitterUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      avatar: json['avatar'] == null
          ? null
          : UploadedFile.fromJson(json['avatar'] as Map<String, dynamic>),
      companyLogo: json['companyLogo'] == null
          ? null
          : UploadedFile.fromJson(json['companyLogo'] as Map<String, dynamic>),
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'company': instance.company,
      'position': instance.position,
      'bio': instance.bio,
      'website': instance.website,
      'linkedinUrl': instance.linkedinUrl,
      'twitterUrl': instance.twitterUrl,
      'instagramUrl': instance.instagramUrl,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'avatar': instance.avatar,
      'companyLogo': instance.companyLogo,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
