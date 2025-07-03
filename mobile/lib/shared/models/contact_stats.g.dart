// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactStats _$ContactStatsFromJson(Map<String, dynamic> json) => ContactStats(
      totalExchanges: (json['totalExchanges'] as num).toInt(),
      weeklyExchanges: (json['weeklyExchanges'] as num).toInt(),
      monthlyExchanges: (json['monthlyExchanges'] as num).toInt(),
      totalViews: (json['totalViews'] as num).toInt(),
      uniqueContacts: (json['uniqueContacts'] as num).toInt(),
      topLocations: (json['topLocations'] as List<dynamic>)
          .map((e) => LocationStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      methodBreakdown: Map<String, int>.from(json['methodBreakdown'] as Map),
      lastExchange: json['lastExchange'] == null
          ? null
          : DateTime.parse(json['lastExchange'] as String),
      averageExchangesPerDay:
          (json['averageExchangesPerDay'] as num?)?.toDouble(),
      conversionRate: (json['conversionRate'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ContactStatsToJson(ContactStats instance) =>
    <String, dynamic>{
      'totalExchanges': instance.totalExchanges,
      'weeklyExchanges': instance.weeklyExchanges,
      'monthlyExchanges': instance.monthlyExchanges,
      'totalViews': instance.totalViews,
      'uniqueContacts': instance.uniqueContacts,
      'topLocations': instance.topLocations,
      'methodBreakdown': instance.methodBreakdown,
      'lastExchange': instance.lastExchange?.toIso8601String(),
      'averageExchangesPerDay': instance.averageExchangesPerDay,
      'conversionRate': instance.conversionRate,
    };

LocationStat _$LocationStatFromJson(Map<String, dynamic> json) => LocationStat(
      name: json['name'] as String,
      count: (json['count'] as num).toInt(),
      country: json['country'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LocationStatToJson(LocationStat instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
