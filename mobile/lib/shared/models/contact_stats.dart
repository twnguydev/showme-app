// mobile/lib/shared/models/contact_stats.dart
import 'package:json_annotation/json_annotation.dart';

part 'contact_stats.g.dart';

@JsonSerializable()
class ContactStats {
  final int totalExchanges;
  final int weeklyExchanges;
  final int monthlyExchanges;
  final int totalViews;
  final int uniqueContacts;
  final List<LocationStat> topLocations;
  final Map<String, int> methodBreakdown;
  final DateTime? lastExchange;
  final double? averageExchangesPerDay;
  final int? conversionRate; // Pourcentage de leads qualifiés

  const ContactStats({
    required this.totalExchanges,
    required this.weeklyExchanges,
    required this.monthlyExchanges,
    required this.totalViews,
    required this.uniqueContacts,
    required this.topLocations,
    required this.methodBreakdown,
    this.lastExchange,
    this.averageExchangesPerDay,
    this.conversionRate,
  });

  factory ContactStats.fromJson(Map<String, dynamic> json) => _$ContactStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ContactStatsToJson(this);

  // Getters calculés
  double get viewsToExchangesRatio {
    if (totalExchanges == 0) return 0.0;
    return totalViews / totalExchanges;
  }

  int get dailyExchanges {
    if (averageExchangesPerDay != null) {
      return averageExchangesPerDay!.round();
    }
    return weeklyExchanges ~/ 7;
  }

  String get mostPopularMethod {
    if (methodBreakdown.isEmpty) return 'Aucun';
    
    var maxEntry = methodBreakdown.entries.first;
    for (var entry in methodBreakdown.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  String get topLocation {
    if (topLocations.isEmpty) return 'Aucune';
    return topLocations.first.name;
  }

  bool get hasGrowth => weeklyExchanges > 0;

  // Calcul du taux de croissance hebdomadaire (estimation)
  double get weeklyGrowthRate {
    if (monthlyExchanges == 0 || weeklyExchanges == 0) return 0.0;
    final averageWeeklyFromMonth = monthlyExchanges / 4;
    return ((weeklyExchanges - averageWeeklyFromMonth) / averageWeeklyFromMonth) * 100;
  }

  ContactStats copyWith({
    int? totalExchanges,
    int? weeklyExchanges,
    int? monthlyExchanges,
    int? totalViews,
    int? uniqueContacts,
    List<LocationStat>? topLocations,
    Map<String, int>? methodBreakdown,
    DateTime? lastExchange,
    double? averageExchangesPerDay,
    int? conversionRate,
  }) {
    return ContactStats(
      totalExchanges: totalExchanges ?? this.totalExchanges,
      weeklyExchanges: weeklyExchanges ?? this.weeklyExchanges,
      monthlyExchanges: monthlyExchanges ?? this.monthlyExchanges,
      totalViews: totalViews ?? this.totalViews,
      uniqueContacts: uniqueContacts ?? this.uniqueContacts,
      topLocations: topLocations ?? this.topLocations,
      methodBreakdown: methodBreakdown ?? this.methodBreakdown,
      lastExchange: lastExchange ?? this.lastExchange,
      averageExchangesPerDay: averageExchangesPerDay ?? this.averageExchangesPerDay,
      conversionRate: conversionRate ?? this.conversionRate,
    );
  }

  static ContactStats demo() {
    return ContactStats(
      totalExchanges: 142,
      weeklyExchanges: 18,
      monthlyExchanges: 65,
      totalViews: 284,
      uniqueContacts: 89,
      topLocations: [
        LocationStat(name: 'Paris', count: 45),
        LocationStat(name: 'Lyon', count: 23),
        LocationStat(name: 'Marseille', count: 12),
        LocationStat(name: 'Toulouse', count: 8),
        LocationStat(name: 'Nice', count: 5),
      ],
      methodBreakdown: {
        'NFC': 45,
        'QR': 38,
        'LINK': 32,
        'KIOSK': 27,
      },
      lastExchange: DateTime.now().subtract(const Duration(hours: 2)),
      averageExchangesPerDay: 2.8,
      conversionRate: 34, // 34% de leads qualifiés
    );
  }

  static ContactStats empty() {
    return const ContactStats(
      totalExchanges: 0,
      weeklyExchanges: 0,
      monthlyExchanges: 0,
      totalViews: 0,
      uniqueContacts: 0,
      topLocations: [],
      methodBreakdown: {},
      lastExchange: null,
      averageExchangesPerDay: 0.0,
      conversionRate: 0,
    );
  }
}

@JsonSerializable()
class LocationStat {
  final String name;
  final int count;
  final String? country;
  final double? latitude;
  final double? longitude;

  const LocationStat({
    required this.name,
    required this.count,
    this.country,
    this.latitude,
    this.longitude,
  });

  factory LocationStat.fromJson(Map<String, dynamic> json) => _$LocationStatFromJson(json);
  Map<String, dynamic> toJson() => _$LocationStatToJson(this);

  String get displayName {
    if (country != null && country != name) {
      return '$name, $country';
    }
    return name;
  }

  LocationStat copyWith({
    String? name,
    int? count,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    return LocationStat(
      name: name ?? this.name,
      count: count ?? this.count,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}