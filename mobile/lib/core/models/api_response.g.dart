// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      meta: json['meta'] as Map<String, dynamic>?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => ApiError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'message': instance.message,
      'success': instance.success,
      'statusCode': instance.statusCode,
      'meta': instance.meta,
      'errors': instance.errors,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
      message: json['message'] as String,
      field: json['field'] as String?,
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
      'message': instance.message,
      'field': instance.field,
      'code': instance.code,
      'details': instance.details,
    };
