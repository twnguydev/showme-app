// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Visitor _$VisitorFromJson(Map<String, dynamic> json) => Visitor(
      id: (json['id'] as num).toInt(),
      deviceHash: json['deviceHash'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VisitorToJson(Visitor instance) => <String, dynamic>{
      'id': instance.id,
      'deviceHash': instance.deviceHash,
      'email': instance.email,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
