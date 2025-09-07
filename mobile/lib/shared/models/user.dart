// mobile/lib/shared/models/user.dart
import 'package:json_annotation/json_annotation.dart';
import 'uploaded_file.dart';
import 'subscription.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue('user')
  user,
  @JsonValue('admin')
  admin,
  @JsonValue('moderator')
  moderator,
}

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final UserRole role;
  final bool emailVerified;
  final String? emailVerificationToken;
  final String? passwordResetToken;
  final DateTime? passwordResetExpires;
  final String? refreshToken;
  final DateTime? lastLoginAt;
  final bool isActive;

  // === DONNÉES DE BASE UTILISATEUR ===
  // Ces données peuvent être utilisées comme valeurs par défaut pour nouvelles cartes
  final String? defaultPhone;
  final String? defaultCompany;
  final String? defaultPosition;
  final UploadedFile? defaultAvatar;

  // === RELATIONS ===
  final Subscription? subscription;

  // === TIMESTAMPS ===
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.role = UserRole.user,
    this.emailVerified = false,
    this.emailVerificationToken,
    this.passwordResetToken,
    this.passwordResetExpires,
    this.refreshToken,
    this.lastLoginAt,
    this.isActive = true,
    this.defaultPhone,
    this.defaultCompany,
    this.defaultPosition,
    this.defaultAvatar,
    this.subscription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // === GETTERS VIRTUELS ===

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email.split('@')[0];
  }

  String get displayName {
    final name = fullName;
    if (name.isNotEmpty && name != email.split('@')[0]) return name;
    return email;
  }

  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    final result = '$first$last'.toUpperCase();
    return result.isNotEmpty ? result : email[0].toUpperCase();
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isModerator => role == UserRole.moderator;
  bool get isStandardUser => role == UserRole.user;
  bool get isPro => subscription?.isActive == true;

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

  // === MÉTHODES ===

  User copyWith({
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    bool? emailVerified,
    String? emailVerificationToken,
    String? passwordResetToken,
    DateTime? passwordResetExpires,
    String? refreshToken,
    DateTime? lastLoginAt,
    bool? isActive,
    String? defaultPhone,
    String? defaultCompany,
    String? defaultPosition,
    UploadedFile? defaultAvatar,
    Subscription? subscription,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerificationToken: emailVerificationToken ?? this.emailVerificationToken,
      passwordResetToken: passwordResetToken ?? this.passwordResetToken,
      passwordResetExpires: passwordResetExpires ?? this.passwordResetExpires,
      refreshToken: refreshToken ?? this.refreshToken,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      defaultPhone: defaultPhone ?? this.defaultPhone,
      defaultCompany: defaultCompany ?? this.defaultCompany,
      defaultPosition: defaultPosition ?? this.defaultPosition,
      defaultAvatar: defaultAvatar ?? this.defaultAvatar,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Méthode pour créer les données d'une carte par défaut pour un nouvel utilisateur
  Map<String, dynamic> createDefaultCardData() {
    return {
      'slug': generateSlug(),
      'title': 'Carte de $fullName',
      'bio': 'Ma carte de contact digitale',
      'isPublic': true,
      'email': email,
      'phone': defaultPhone,
      'company': defaultCompany,
      'position': defaultPosition,
    };
  }

  String generateSlug() {
    final base = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
    
    return base.isNotEmpty ? base : 'user-$id';
  }

  static User demo() {
    final now = DateTime.now();
    return User(
      id: 1,
      email: 'tanguy.gbt@showme.com',
      firstName: 'Tanguy',
      lastName: 'Gbty',
      role: UserRole.user,
      isActive: true,
      emailVerified: true,
      lastLoginAt: now.subtract(const Duration(minutes: 5)),
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      defaultPhone: '+33 6 12 34 56 78',
      defaultCompany: 'ShowMe',
      defaultPosition: 'Développeur',
    );
  }
}