// mobile/lib/shared/models/card.dart
import 'package:json_annotation/json_annotation.dart';
import 'profile.dart';
import 'subscription.dart';
import 'uploaded_file.dart';
import 'card_theme.dart';

part 'card.g.dart';

@JsonSerializable()
class Card {
  final int id;
  final String slug;
  final String title;
  final String? bio;
  final bool isPublic;
  final int viewsCount;
  final String? walletPassUrl;
  final bool allowPayment;
  final bool nfcEnabled;
  final UploadedFile? qrCodeUrl;
  final int totalShared;
  final int totalLeads;
  final Profile profile;
  final Subscription? subscription;
  final CardTheme theme;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Card({
    required this.id,
    required this.slug,
    required this.title,
    this.bio,
    required this.isPublic,
    required this.viewsCount,
    this.walletPassUrl,
    required this.allowPayment,
    required this.nfcEnabled,
    this.qrCodeUrl,
    required this.totalShared,
    required this.totalLeads,
    required this.profile,
    this.subscription,
    this.theme = CardTheme.purple,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);

  String get publicUrl => 'https://showmeapp.com/card/$slug';
  String get shortUrl => 'https://showme.app/u/$slug';
  
  bool get isPro => subscription?.isActive == true;
  bool get canUseAdvancedFeatures => isPro;
  
  Card copyWith({
    String? slug,
    String? title,
    String? bio,
    bool? isPublic,
    int? viewsCount,
    String? walletPassUrl,
    bool? allowPayment,
    bool? nfcEnabled,
    UploadedFile? qrCodeUrl,
    int? totalShared,
    int? totalLeads,
    Profile? profile,
    Subscription? subscription,
    CardTheme? theme,
  }) {
    return Card(
      id: id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      isPublic: isPublic ?? this.isPublic,
      viewsCount: viewsCount ?? this.viewsCount,
      walletPassUrl: walletPassUrl ?? this.walletPassUrl,
      allowPayment: allowPayment ?? this.allowPayment,
      nfcEnabled: nfcEnabled ?? this.nfcEnabled,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      totalShared: totalShared ?? this.totalShared,
      totalLeads: totalLeads ?? this.totalLeads,
      profile: profile ?? this.profile,
      subscription: subscription ?? this.subscription,
      theme: theme ?? this.theme, // Updated
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Card demo() {
    final now = DateTime.now();
    return Card(
      id: 1,
      slug: 'jean-dupont',
      title: 'Ma carte premium',
      bio: 'Expert en transformation digitale avec 10+ ans d\'expérience. Je vous accompagne dans vos projets les plus ambitieux.',
      isPublic: true,
      viewsCount: 156,
      walletPassUrl: null,
      allowPayment: true,
      nfcEnabled: true,
      qrCodeUrl: UploadedFile.demo(),
      totalShared: 42,
      totalLeads: 18,
      profile: Profile.demo(),
      subscription: Subscription.demo(),
      theme: CardTheme.purple,
      createdAt: now,
      updatedAt: now,
    );
  }
}