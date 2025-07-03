// mobile/lib/shared/models/profile.dart
import 'package:json_annotation/json_annotation.dart';
import 'uploaded_file.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? company;
  final String? position;
  final String? bio;
  final String? website;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? address;
  final String? city;
  final String? country;
  final UploadedFile? avatar;
  final UploadedFile? companyLogo;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.company,
    this.position,
    this.bio,
    this.website,
    this.linkedinUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.address,
    this.city,
    this.country,
    this.avatar,
    this.companyLogo,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    return '$first$last'.toUpperCase();
  }

  String get displayName => fullName.isNotEmpty ? fullName : email ?? 'Utilisateur';

  String? get fullAddress {
    final parts = [address, city, country].where((part) => part?.isNotEmpty == true);
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  bool get hasContactInfo => phone != null || email != null;
  bool get hasSocialLinks => linkedinUrl != null || twitterUrl != null || instagramUrl != null;
  bool get hasCompanyInfo => company != null || position != null;

  Profile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? company,
    String? position,
    String? bio,
    String? website,
    String? linkedinUrl,
    String? twitterUrl,
    String? instagramUrl,
    String? address,
    String? city,
    String? country,
    UploadedFile? avatar,
    UploadedFile? companyLogo,
    bool? isPublic,
  }) {
    return Profile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      position: position ?? this.position,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      avatar: avatar ?? this.avatar,
      companyLogo: companyLogo ?? this.companyLogo,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Profile demo() {
    final now = DateTime.now();
    return Profile(
      id: 1,
      firstName: 'Jean',
      lastName: 'Dupont',
      email: 'jean.dupont@showme.com',
      phone: '+33 6 12 34 56 78',
      company: 'Showme Corp',
      position: 'Consultant Senior',
      bio: 'Expert en transformation digitale avec 10+ ans d\'expérience.',
      website: 'https://jeandupont.com',
      linkedinUrl: 'https://linkedin.com/in/jean-dupont',
      twitterUrl: null,
      instagramUrl: null,
      address: '123 Rue de la Tech',
      city: 'Paris',
      country: 'France',
      avatar: UploadedFile(
        url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        name: 'avatar.jpg',
        size: 1024 * 100, // 100KB
        mimeType: 'image/jpeg',
      ),
      companyLogo: UploadedFile(
        url: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop',
        name: 'logo.png',
        size: 1024 * 50, // 50KB
        mimeType: 'image/png',
      ),
      isPublic: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}