// mobile/lib/features/profile/bloc/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import 'profile_event.dart';
import 'profile_state.dart';
import '../../../core/services/api_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService;

  ProfileBloc({required ApiService apiService})
      : _apiService = apiService,
        super(ProfileInitial()) {
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileAvatarUploadRequested>(_onProfileAvatarUploadRequested);
    on<ProfilePasswordChangeRequested>(_onProfilePasswordChangeRequested);
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());

    try {
      final response = await _apiService.updateProfile(event.updateData);
      emit(ProfileUpdateSuccess(response.data));
    } catch (e) {
      emit(ProfileUpdateError(_getErrorMessage(e)));
    }
  }

  Future<void> _onProfileAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileAvatarUploadLoading());

    try {
      final response = await _apiService.uploadAvatar(event.imageFile);
      emit(ProfileAvatarUploadSuccess(response.data?['url']));
    } catch (e) {
      emit(ProfileAvatarUploadError(_getErrorMessage(e)));
    }
  }

  Future<void> _onProfilePasswordChangeRequested(
    ProfilePasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfilePasswordChangeLoading());

    try {
      await _apiService.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(ProfilePasswordChangeSuccess());
    } catch (e) {
      emit(ProfilePasswordChangeError(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    } else if (error.toString().contains('401')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    } else if (error.toString().contains('403')) {
      return 'Vous n\'êtes pas autorisé à effectuer cette action.';
    } else if (error.toString().contains('422')) {
      return 'Données invalides. Vérifiez vos informations.';
    }
    return 'Une erreur inattendue s\'est produite.';
  }
}