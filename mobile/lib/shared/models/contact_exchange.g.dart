// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_exchange.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactExchange _$ContactExchangeFromJson(Map<String, dynamic> json) =>
    ContactExchange(
      id: (json['id'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      geoLocation: json['geoLocation'] as Map<String, dynamic>?,
      userAgent: json['userAgent'] as String?,
      referrer: $enumDecode(_$ExchangeMethodEnumMap, json['referrer']),
      openedOnWallet: json['openedOnWallet'] as bool,
      contactAdded: json['contactAdded'] as bool,
      emailSubmitted: json['emailSubmitted'] as String?,
      deviceType: $enumDecode(_$DeviceTypeEnumMap, json['deviceType']),
      card: Card.fromJson(json['card'] as Map<String, dynamic>),
      visitor: json['visitor'] == null
          ? null
          : Visitor.fromJson(json['visitor'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ContactExchangeToJson(ContactExchange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'geoLocation': instance.geoLocation,
      'userAgent': instance.userAgent,
      'referrer': _$ExchangeMethodEnumMap[instance.referrer]!,
      'openedOnWallet': instance.openedOnWallet,
      'contactAdded': instance.contactAdded,
      'emailSubmitted': instance.emailSubmitted,
      'deviceType': _$DeviceTypeEnumMap[instance.deviceType]!,
      'card': instance.card,
      'visitor': instance.visitor,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ExchangeMethodEnumMap = {
  ExchangeMethod.nfc: 'nfc',
  ExchangeMethod.qr: 'qr',
  ExchangeMethod.link: 'link',
  ExchangeMethod.kiosk: 'kiosk',
};

const _$DeviceTypeEnumMap = {
  DeviceType.ios: 'ios',
  DeviceType.android: 'android',
  DeviceType.web: 'web',
  DeviceType.unknown: 'unknown',
};
