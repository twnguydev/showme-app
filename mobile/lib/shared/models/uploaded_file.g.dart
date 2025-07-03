// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uploaded_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadedFile _$UploadedFileFromJson(Map<String, dynamic> json) => UploadedFile(
      url: json['url'] as String,
      name: json['name'] as String?,
      size: (json['size'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$UploadedFileToJson(UploadedFile instance) =>
    <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'size': instance.size,
      'mimeType': instance.mimeType,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };
