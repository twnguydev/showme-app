// mobile/lib/features/profile/bloc/profile_event.dart
import 'dart:io';

abstract class ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final Map<String, dynamic> updateData;
  
  ProfileUpdateRequested(this.updateData);
}

class ProfileAvatarUploadRequested extends ProfileEvent {
  final File imageFile;
  
  ProfileAvatarUploadRequested(this.imageFile);
}

class ProfilePasswordChangeRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  
  ProfilePasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });
}