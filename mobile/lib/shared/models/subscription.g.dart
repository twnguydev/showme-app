// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
      id: (json['id'] as num).toInt(),
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      billingPeriod: $enumDecode(_$BillingPeriodEnumMap, json['billingPeriod']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      trialEndDate: json['trialEndDate'] == null
          ? null
          : DateTime.parse(json['trialEndDate'] as String),
      canceledAt: json['canceledAt'] == null
          ? null
          : DateTime.parse(json['canceledAt'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      externalSubscriptionId: json['externalSubscriptionId'] as String?,
      features: json['features'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'planName': instance.planName,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'price': instance.price,
      'currency': instance.currency,
      'billingPeriod': _$BillingPeriodEnumMap[instance.billingPeriod]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'trialEndDate': instance.trialEndDate?.toIso8601String(),
      'canceledAt': instance.canceledAt?.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'externalSubscriptionId': instance.externalSubscriptionId,
      'features': instance.features,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.pending: 'pending',
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.trialing: 'trialing',
  SubscriptionStatus.canceled: 'canceled',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.paused: 'paused',
};

const _$BillingPeriodEnumMap = {
  BillingPeriod.weekly: 'weekly',
  BillingPeriod.monthly: 'monthly',
  BillingPeriod.yearly: 'yearly',
  BillingPeriod.lifetime: 'lifetime',
};
