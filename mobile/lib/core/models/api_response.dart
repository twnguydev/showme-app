// mobile/lib/core/models/api_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;
  final Map<String, dynamic>? meta;
  final List<ApiError>? errors;

  const ApiResponse({
    this.data,
    this.message,
    this.success = true,
    this.statusCode,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  // Factory constructors pour faciliter l'utilisation
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode ?? 200,
      meta: meta,
    );
  }

  factory ApiResponse.error({
    String? message,
    int? statusCode,
    List<ApiError>? errors,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      message: message,
      success: false,
      statusCode: statusCode ?? 400,
      errors: errors,
      meta: meta,
    );
  }

  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get hasMeta => meta != null && meta!.isNotEmpty;

  String get errorMessage {
    if (message != null) return message!;
    if (hasErrors) return errors!.first.message;
    return 'Une erreur inconnue s\'est produite';
  }

  List<String> get allErrorMessages {
    final messages = <String>[];
    if (message != null) messages.add(message!);
    if (hasErrors) {
      messages.addAll(errors!.map((e) => e.message));
    }
    return messages;
  }

  ApiResponse<T> copyWith({
    T? data,
    String? message,
    bool? success,
    int? statusCode,
    Map<String, dynamic>? meta,
    List<ApiError>? errors,
  }) {
    return ApiResponse<T>(
      data: data ?? this.data,
      message: message ?? this.message,
      success: success ?? this.success,
      statusCode: statusCode ?? this.statusCode,
      meta: meta ?? this.meta,
      errors: errors ?? this.errors,
    );
  }
}

@JsonSerializable()
class ApiError {
  final String message;
  final String? field;
  final String? code;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.message,
    this.field,
    this.code,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  bool get hasField => field != null;
  bool get hasCode => code != null;
  bool get hasDetails => details != null && details!.isNotEmpty;

  ApiError copyWith({
    String? message,
    String? field,
    String? code,
    Map<String, dynamic>? details,
  }) {
    return ApiError(
      message: message ?? this.message,
      field: field ?? this.field,
      code: code ?? this.code,
      details: details ?? this.details,
    );
  }
}

// Extensions utiles pour faciliter l'utilisation
extension ApiResponseExtensions<T> on ApiResponse<T> {
  bool get isSuccess => success && !hasErrors;
  bool get isFailure => !success || hasErrors;
  
  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  
  T? get dataOrNull => isSuccess ? data : null;
  
  T getDataOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw ApiException(errorMessage, statusCode);
  }
}

// Exception personnalisée pour les erreurs d'API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<ApiError>? errors;

  const ApiException(this.message, [this.statusCode, this.errors]);

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}