// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_pass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletPass _$WalletPassFromJson(Map<String, dynamic> json) => WalletPass(
      id: (json['id'] as num).toInt(),
      passTypeIdentifier: json['passTypeIdentifier'] as String,
      serialNumber: json['serialNumber'] as String,
      passUrl: json['passUrl'] as String?,
      qrCodeMedia: json['qrCodeMedia'] == null
          ? null
          : UploadedFile.fromJson(json['qrCodeMedia'] as Map<String, dynamic>),
      status: $enumDecode(_$PassStatusEnumMap, json['status']),
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      card: Card.fromJson(json['card'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WalletPassToJson(WalletPass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'passTypeIdentifier': instance.passTypeIdentifier,
      'serialNumber': instance.serialNumber,
      'passUrl': instance.passUrl,
      'qrCodeMedia': instance.qrCodeMedia,
      'status': _$PassStatusEnumMap[instance.status]!,
      'generatedAt': instance.generatedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'card': instance.card,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PassStatusEnumMap = {
  PassStatus.pending: 'pending',
  PassStatus.active: 'active',
  PassStatus.revoked: 'revoked',
  PassStatus.error: 'error',
};
