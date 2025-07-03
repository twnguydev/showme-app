// mobile/lib/shared/models/user.dart
import 'package:json_annotation/json_annotation.dart';
import 'uploaded_file.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? position;
  final String? phoneNumber;
  final String? linkedinUrl;
  final String? website;
  final UploadedFile? profilePicture;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserRole role;
  final bool emailVerified;
  final String? timezone;
  final String? language;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.company,
    this.position,
    this.phoneNumber,
    this.linkedinUrl,
    this.website,
    this.profilePicture,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.role = UserRole.user,
    this.emailVerified = false,
    this.timezone,
    this.language,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  String get displayName {
    final name = fullName;
    if (name.isNotEmpty) return name;
    return email;
  }

  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    final result = '$first$last'.toUpperCase();
    return result.isNotEmpty ? result : email[0].toUpperCase();
  }

  bool get hasProfilePicture => profilePicture != null;
  
  bool get isAdmin => role == UserRole.admin;
  bool get isModerator => role == UserRole.moderator;
  bool get isStandardUser => role == UserRole.user;

  bool get hasCompanyInfo => company != null || position != null;
  bool get hasContactInfo => phoneNumber != null || linkedinUrl != null || website != null;

  String get memberSince {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 30) {
      return 'Membre depuis ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Membre depuis $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Membre depuis $years an${years > 1 ? 's' : ''}';
    }
  }

  bool get isOnline {
    if (lastLoginAt == null) return false;
    return DateTime.now().difference(lastLoginAt!).inMinutes < 15;
  }

  User copyWith({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? company,
    String? position,
    String? phoneNumber,
    String? linkedinUrl,
    String? website,
    UploadedFile? profilePicture,
    bool? isActive,
    DateTime? lastLoginAt,
    UserRole? role,
    bool? emailVerified,
    String? timezone,
    String? language,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      position: position ?? this.position,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      website: website ?? this.website,
      profilePicture: profilePicture ?? this.profilePicture,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
    );
  }

  static User demo() {
    final now = DateTime.now();
    return User(
      id: 1,
      username: 'jean.dupont',
      email: 'jean.dupont@showme.com',
      firstName: 'Jean',
      lastName: 'Dupont',
      company: 'Showme Corp',
      position: 'Consultant Senior',
      phoneNumber: '+33 6 12 34 56 78',
      linkedinUrl: 'https://linkedin.com/in/jean-dupont',
      website: 'https://jeandupont.com',
      profilePicture: UploadedFile(
        url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        name: 'profile.jpg',
        size: 1024 * 150, // 150KB
        mimeType: 'image/jpeg',
      ),
      isActive: true,
      lastLoginAt: now.subtract(const Duration(minutes: 5)),
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      role: UserRole.user,
      emailVerified: true,
      timezone: 'Europe/Paris',
      language: 'fr',
    );
  }
}

@JsonEnum()
enum UserRole {
  @JsonValue('user')
  user,
  @JsonValue('moderator')
  moderator,
  @JsonValue('admin')
  admin,
}