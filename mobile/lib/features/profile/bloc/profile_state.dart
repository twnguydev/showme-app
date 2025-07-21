// mobile/lib/features/profile/bloc/profile_state.dart
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final dynamic user;
  
  ProfileUpdateSuccess(this.user);
}

class ProfileUpdateError extends ProfileState {
  final String message;
  
  ProfileUpdateError(this.message);
}

class ProfileAvatarUploadLoading extends ProfileState {}

class ProfileAvatarUploadSuccess extends ProfileState {
  final String avatarUrl;
  
  ProfileAvatarUploadSuccess(this.avatarUrl);
}

class ProfileAvatarUploadError extends ProfileState {
  final String message;
  
  ProfileAvatarUploadError(this.message);
}

class ProfilePasswordChangeLoading extends ProfileState {}

class ProfilePasswordChangeSuccess extends ProfileState {}

class ProfilePasswordChangeError extends ProfileState {
  final String message;
  
  ProfilePasswordChangeError(this.message);
}