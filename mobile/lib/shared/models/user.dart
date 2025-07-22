// mobile/lib/shared/models/user.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:showme/shared/models/profile.dart';
import 'uploaded_file.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String role; // API renvoie String, pas enum
  final bool emailVerified;
  final String? timezone;
  final String? language;
  final Profile? profile;
  
  // Champs supplémentaires de l'API que vous n'aviez pas
  final String? emailVerificationToken;
  final String? passwordResetToken;
  final DateTime? passwordResetExpires;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.role = 'user',
    this.emailVerified = false,
    this.timezone,
    this.language,
    this.profile,
    this.emailVerificationToken,
    this.passwordResetToken,
    this.passwordResetExpires,
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

  bool get hasProfilePicture => profile?.avatar != null && profile!.avatar!.url.isNotEmpty;

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isStandardUser => role == 'user';

  bool get hasCompanyInfo => profile?.company != null || profile?.position != null;
  bool get hasContactInfo => profile?.phone != null || profile?.linkedinUrl != null || profile?.website != null;

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
    String? role,
    bool? emailVerified,
    String? timezone,
    String? language,
    Profile? profile,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      profile: profile ?? this.profile,
      emailVerificationToken: emailVerificationToken,
      passwordResetToken: passwordResetToken,
      passwordResetExpires: passwordResetExpires,
    );
  }

  static User demo() {
    final now = DateTime.now();
    return User(
      id: 1,
      username: 'tanguy.gbt',
      email: 'tanguy.gbt@showme.com',
      firstName: 'Tanguy',
      lastName: 'Gbty',
      isActive: true,
      lastLoginAt: now.subtract(const Duration(minutes: 5)),
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      role: 'user',
      emailVerified: true,
      timezone: 'Europe/Paris',
      language: 'fr',
      profile: Profile.demo(),
    );
  }
}