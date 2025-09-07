// mobile/lib/shared/models/card.dart
import 'package:json_annotation/json_annotation.dart';
import 'card_theme.dart';

part 'card.g.dart';

@JsonSerializable()
class Card {
  final int id;
  final String slug;
  final String title;
  final String publicUrl;
  final String? bio;
  final bool isPublic;
  final int viewsCount;
  final String? walletPassUrl;
  final bool allowPayment;
  final bool nfcEnabled;
  final String? qrCodeUrl;
  final int totalShared;
  final int totalLeads;
  final CardTheme theme;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? company;
  final String? position;
  final String? website;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? address;
  final String? city;
  final String? country;
  final String? avatar;
  final String? companyLogo;

  // Relations
  final int userId;
  final dynamic subscription;

  Card({
    required this.id,
    required this.slug,
    required this.title,
    required this.publicUrl,
    this.bio,
    required this.isPublic,
    required this.viewsCount,
    this.walletPassUrl,
    required this.allowPayment,
    required this.nfcEnabled,
    this.qrCodeUrl,
    required this.totalShared,
    required this.totalLeads,
    required this.theme,
    required this.createdAt,
    required this.updatedAt,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.company,
    this.position,
    this.website,
    this.linkedinUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.address,
    this.city,
    this.country,
    this.avatar,
    this.companyLogo,
    required this.userId,
    this.subscription,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      title: json['title'] ?? 'Carte sans titre',
      publicUrl: json['publicUrl'] ?? '',
      bio: json['bio'],
      isPublic: json['isPublic'] ?? true,
      viewsCount: json['viewsCount'] ?? 0,
      walletPassUrl: json['walletPassUrl'],
      allowPayment: json['allowPayment'] ?? false,
      nfcEnabled: json['nfcEnabled'] ?? false,
      qrCodeUrl: json['qrCodeUrl'],
      totalShared: json['totalShared'] ?? 0,
      totalLeads: json['totalLeads'] ?? 0,
      theme: _parseTheme(json['theme']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      // Données de contact
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      company: json['company'],
      position: json['position'],
      website: json['website'],
      linkedinUrl: json['linkedinUrl'],
      twitterUrl: json['twitterUrl'],
      instagramUrl: json['instagramUrl'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      avatar: json['avatar'],
      companyLogo: json['companyLogo'],
      userId: json['userId'] ?? 0,
      subscription: json['subscription'],
    );
  }

  // Méthode copyWith pour les mises à jour
  Card copyWith({
    String? title,
    String? bio,
    bool? isPublic,
    int? viewsCount,
    bool? allowPayment,
    bool? nfcEnabled,
    int? totalShared,
    int? totalLeads,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? company,
    String? position,
    String? website,
    String? linkedinUrl,
    String? avatar,
    String? companyLogo,
  }) {
    return Card(
      id: id,
      slug: slug,
      title: title ?? this.title,
      publicUrl: publicUrl,
      bio: bio ?? this.bio,
      isPublic: isPublic ?? this.isPublic,
      viewsCount: viewsCount ?? this.viewsCount,
      walletPassUrl: walletPassUrl,
      allowPayment: allowPayment ?? this.allowPayment,
      nfcEnabled: nfcEnabled ?? this.nfcEnabled,
      qrCodeUrl: qrCodeUrl,
      totalShared: totalShared ?? this.totalShared,
      totalLeads: totalLeads ?? this.totalLeads,
      theme: theme,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      position: position ?? this.position,
      website: website ?? this.website,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterUrl: twitterUrl,
      instagramUrl: instagramUrl,
      address: address,
      city: city,
      country: country,
      avatar: avatar ?? this.avatar,
      companyLogo: companyLogo ?? this.companyLogo,
      userId: userId,
      subscription: subscription,
    );
  }

  // Getter pour compatibilité
  bool get isPro => subscription != null;

  // Getter pour nom complet
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email.split('@').first; // Fallback sur l'email
  }

  static CardTheme _parseTheme(dynamic theme) {
    if (theme == null) return CardTheme.purple;

    if (theme is String) {
      switch (theme.toLowerCase()) {
        case 'purple':
          return CardTheme.purple;
        case 'blue':
          return CardTheme.blue;
        case 'teal':
          return CardTheme.teal;
        case 'green':
          return CardTheme.green;
        case 'pink':
          return CardTheme.pink;
        case 'amber':
          return CardTheme.amber;
        default:
          return CardTheme.purple;
      }
    }

    return CardTheme.purple;
  }
}
