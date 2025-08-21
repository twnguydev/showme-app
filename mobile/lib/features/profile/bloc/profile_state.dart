// mobile/lib/features/profile/bloc/profile_state.dart
import 'package:equatable/equatable.dart';
import '../../../shared/models/user.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

// États pour la mise à jour du profil
class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final User user;

  ProfileUpdateSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class ProfileUpdateError extends ProfileState {
  final String message;

  ProfileUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

// États pour l'upload d'avatar
class ProfileAvatarUploadLoading extends ProfileState {}

class ProfileAvatarUploadSuccess extends ProfileState {
  final String? avatarUrl;

  ProfileAvatarUploadSuccess(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class ProfileAvatarUploadError extends ProfileState {
  final String message;

  ProfileAvatarUploadError(this.message);

  @override
  List<Object> get props => [message];
}

// États pour le changement de mot de passe
class ProfilePasswordChangeLoading extends ProfileState {}

class ProfilePasswordChangeSuccess extends ProfileState {}

class ProfilePasswordChangeError extends ProfileState {
  final String message;

  ProfilePasswordChangeError(this.message);

  @override
  List<Object> get props => [message];
}