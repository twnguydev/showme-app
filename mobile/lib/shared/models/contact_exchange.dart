// mobile/lib/shared/models/contact_exchange.dart
import 'package:json_annotation/json_annotation.dart';
import 'card.dart';
import 'visitor.dart';

part 'contact_exchange.g.dart';

enum ExchangeMethod { nfc, qr, link, kiosk }
enum DeviceType { ios, android, web, unknown }

@JsonSerializable()
class ContactExchange {
  final int id;
  final DateTime timestamp;
  final Map<String, dynamic>? geoLocation; // {lat, lng, city, country}
  final String? userAgent;
  final ExchangeMethod referrer;
  final bool openedOnWallet;
  final bool contactAdded;
  final String? emailSubmitted;
  final DeviceType deviceType;
  final Card card;
  final Visitor? visitor;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContactExchange({
    required this.id,
    required this.timestamp,
    this.geoLocation,
    this.userAgent,
    required this.referrer,
    required this.openedOnWallet,
    required this.contactAdded,
    this.emailSubmitted,
    required this.deviceType,
    required this.card,
    this.visitor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContactExchange.fromJson(Map<String, dynamic> json) => _$ContactExchangeFromJson(json);
  Map<String, dynamic> toJson() => _$ContactExchangeToJson(this);

  String get displayMethod {
    switch (referrer) {
      case ExchangeMethod.nfc:
        return 'NFC';
      case ExchangeMethod.qr:
        return 'QR Code';
      case ExchangeMethod.link:
        return 'Lien';
      case ExchangeMethod.kiosk:
        return 'Kiosque';
    }
  }

  String get displayDevice {
    switch (deviceType) {
      case DeviceType.ios:
        return 'iPhone';
      case DeviceType.android:
        return 'Android';
      case DeviceType.web:
        return 'Web';
      case DeviceType.unknown:
        return 'Inconnu';
    }
  }

  String get locationName {
    if (geoLocation == null) return 'Lieu inconnu';
    return geoLocation!['city'] ?? geoLocation!['country'] ?? 'Lieu inconnu';
  }

  bool get hasGeoLocation => geoLocation != null;
  bool get isQualifiedLead => emailSubmitted != null || contactAdded;
}