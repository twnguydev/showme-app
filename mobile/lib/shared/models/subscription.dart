// mobile/lib/shared/models/subscription.dart
import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription {
  final int id;
  final String planId;
  final String planName;
  final SubscriptionStatus status;
  final double price;
  final String currency;
  final BillingPeriod billingPeriod;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final DateTime? canceledAt;
  final String? paymentMethod;
  final String? externalSubscriptionId;
  final Map<String, dynamic>? features;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.startDate,
    this.endDate,
    this.trialEndDate,
    this.canceledAt,
    this.paymentMethod,
    this.externalSubscriptionId,
    this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPending => status == SubscriptionStatus.pending;
  bool get isCanceled => status == SubscriptionStatus.canceled;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isTrialing => status == SubscriptionStatus.trialing;

  bool get isTrialActive => isTrialing && trialEndDate != null && trialEndDate!.isAfter(DateTime.now());
  bool get isTrialExpired => trialEndDate != null && trialEndDate!.isBefore(DateTime.now());

  bool get willExpire => endDate != null && endDate!.isAfter(DateTime.now());
  DateTime? get expirationDate => endDate;

  int? get daysUntilExpiration {
    if (endDate == null) return null;
    final difference = endDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  String get statusDisplay {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Actif';
      case SubscriptionStatus.trialing:
        return 'Période d\'essai';
      case SubscriptionStatus.pending:
        return 'En attente';
      case SubscriptionStatus.canceled:
        return 'Annulé';
      case SubscriptionStatus.expired:
        return 'Expiré';
      case SubscriptionStatus.paused:
        return 'En pause';
    }
  }

  String get billingPeriodDisplay {
    switch (billingPeriod) {
      case BillingPeriod.monthly:
        return 'Mensuel';
      case BillingPeriod.yearly:
        return 'Annuel';
      case BillingPeriod.weekly:
        return 'Hebdomadaire';
      case BillingPeriod.lifetime:
        return 'À vie';
    }
  }

  String get priceDisplay {
    final formattedPrice = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    switch (billingPeriod) {
      case BillingPeriod.monthly:
        return '$formattedPrice $currency/mois';
      case BillingPeriod.yearly:
        return '$formattedPrice $currency/an';
      case BillingPeriod.weekly:
        return '$formattedPrice $currency/semaine';
      case BillingPeriod.lifetime:
        return '$formattedPrice $currency (à vie)';
    }
  }

  // Vérifier si une fonctionnalité est disponible
  bool hasFeature(String featureName) {
    if (features == null) return false;
    return features![featureName] == true;
  }

  // Obtenir la limite d'une fonctionnalité
  int? getFeatureLimit(String featureName) {
    if (features == null) return null;
    final value = features![featureName];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Subscription copyWith({
    String? planId,
    String? planName,
    SubscriptionStatus? status,
    double? price,
    String? currency,
    BillingPeriod? billingPeriod,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    DateTime? canceledAt,
    String? paymentMethod,
    String? externalSubscriptionId,
    Map<String, dynamic>? features,
  }) {
    return Subscription(
      id: id,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      canceledAt: canceledAt ?? this.canceledAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      externalSubscriptionId: externalSubscriptionId ?? this.externalSubscriptionId,
      features: features ?? this.features,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Subscription demo() {
    final now = DateTime.now();
    return Subscription(
      id: 1,
      planId: 'pro_monthly',
      planName: 'Plan Pro',
      status: SubscriptionStatus.active,
      price: 29.99,
      currency: 'EUR',
      billingPeriod: BillingPeriod.monthly,
      startDate: now.subtract(const Duration(days: 15)),
      endDate: now.add(const Duration(days: 15)),
      trialEndDate: null,
      canceledAt: null,
      paymentMethod: 'card_****1234',
      externalSubscriptionId: 'sub_1234567890',
      features: {
        'unlimited_cards': true,
        'custom_design': true,
        'analytics': true,
        'api_access': true,
        'max_team_members': 10,
        'storage_gb': 50,
      },
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now,
    );
  }
}

@JsonEnum()
enum SubscriptionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('trialing')
  trialing,
  @JsonValue('canceled')
  canceled,
  @JsonValue('expired')
  expired,
  @JsonValue('paused')
  paused,
}

@JsonEnum()
enum BillingPeriod {
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
  @JsonValue('lifetime')
  lifetime,
}