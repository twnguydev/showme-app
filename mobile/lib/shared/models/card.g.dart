// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Card _$CardFromJson(Map<String, dynamic> json) => Card(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      title: json['title'] as String,
      bio: json['bio'] as String?,
      isPublic: json['isPublic'] as bool,
      viewsCount: (json['viewsCount'] as num).toInt(),
      walletPassUrl: json['walletPassUrl'] as String?,
      allowPayment: json['allowPayment'] as bool,
      nfcEnabled: json['nfcEnabled'] as bool,
      qrCodeUrl: json['qrCodeUrl'] == null
          ? null
          : UploadedFile.fromJson(json['qrCodeUrl'] as Map<String, dynamic>),
      totalShared: (json['totalShared'] as num).toInt(),
      totalLeads: (json['totalLeads'] as num).toInt(),
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      subscription: json['subscription'] == null
          ? null
          : Subscription.fromJson(json['subscription'] as Map<String, dynamic>),
      theme: $enumDecodeNullable(_$CardThemeEnumMap, json['theme']) ??
          CardTheme.purple,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CardToJson(Card instance) => <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'bio': instance.bio,
      'isPublic': instance.isPublic,
      'viewsCount': instance.viewsCount,
      'walletPassUrl': instance.walletPassUrl,
      'allowPayment': instance.allowPayment,
      'nfcEnabled': instance.nfcEnabled,
      'qrCodeUrl': instance.qrCodeUrl,
      'totalShared': instance.totalShared,
      'totalLeads': instance.totalLeads,
      'profile': instance.profile,
      'subscription': instance.subscription,
      'theme': _$CardThemeEnumMap[instance.theme]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CardThemeEnumMap = {
  CardTheme.purple: 'purple',
  CardTheme.blue: 'blue',
  CardTheme.teal: 'teal',
  CardTheme.green: 'green',
  CardTheme.orange: 'orange',
  CardTheme.red: 'red',
  CardTheme.pink: 'pink',
  CardTheme.indigo: 'indigo',
  CardTheme.emerald: 'emerald',
  CardTheme.amber: 'amber',
};
