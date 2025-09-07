// mobile/lib/features/profile/bloc/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'profile_event.dart';
import 'profile_state.dart';
import '../../../core/services/users_api_service.dart';
import '../../../features/auth/data/repositories/auth_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UsersApiService _usersApiService;

  ProfileBloc({required UsersApiService usersApiService})
      : _usersApiService = usersApiService,
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
      final response = await _usersApiService.updateProfile(event.updateData);
      emit(ProfileUpdateSuccess(response.data!));
    } on AuthException catch (e) {
      emit(ProfileUpdateError(e.message));
    } on DioException catch (e) {
      emit(ProfileUpdateError(_handleDioError(e)));
    } catch (e) {
      emit(ProfileUpdateError('Une erreur inattendue s\'est produite'));
    }
  }

  Future<void> _onProfileAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileAvatarUploadLoading());

    try {
      // L'upload d'avatar retourne maintenant l'utilisateur mis à jour
      final response = await _usersApiService.uploadAvatar(event.imageFile);
      
      // Émettre le succès avec l'URL de l'avatar
      emit(ProfileAvatarUploadSuccess(response.data!.defaultAvatar!.url));
    } on AuthException catch (e) {
      emit(ProfileAvatarUploadError(e.message));
    } on DioException catch (e) {
      emit(ProfileAvatarUploadError(_handleDioError(e)));
    } catch (e) {
      emit(ProfileAvatarUploadError('Erreur lors de l\'upload de l\'avatar'));
    }
  }

  Future<void> _onProfilePasswordChangeRequested(
    ProfilePasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfilePasswordChangeLoading());

    try {
      await _usersApiService.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(ProfilePasswordChangeSuccess());
    } on AuthException catch (e) {
      emit(ProfilePasswordChangeError(e.message));
    } on DioException catch (e) {
      emit(ProfilePasswordChangeError(_handleDioError(e)));
    } catch (e) {
      emit(ProfilePasswordChangeError('Erreur lors du changement de mot de passe'));
    }
  }

  /// Gère les erreurs DioException de manière centralisée
  String _handleDioError(DioException e) {
    print('🚨 ProfileBloc DioError: ${e.response?.data}');
    
    if (e.response?.data != null) {
      final data = e.response!.data;
      
      // Gérer les messages d'erreur du backend NestJS
      if (data is Map<String, dynamic>) {
        // Si le message est un tableau (erreurs de validation)
        if (data.containsKey('message') && data['message'] is List) {
          final messages = data['message'] as List;
          return messages.isNotEmpty 
            ? messages.first.toString() 
            : 'Erreur de validation';
        }
        
        // Si le message est une chaîne simple
        if (data.containsKey('message') && data['message'] is String) {
          return data['message'] as String;
        }
        
        // Si on a un champ error
        if (data.containsKey('error') && data['error'] is String) {
          return data['error'] as String;
        }
      }
    }

    // Messages d'erreur par défaut selon le code de statut
    switch (e.response?.statusCode) {
      case 400:
        return 'Données invalides';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Vous n\'êtes pas autorisé à effectuer cette action';
      case 404:
        return 'Ressource non trouvée';
      case 409:
        return 'Conflit - ressource déjà existante';
      case 422:
        return 'Données de validation incorrectes';
      case 500:
        return 'Erreur serveur, veuillez réessayer';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return 'Connexion lente, veuillez réessayer';
        } else if (e.type == DioExceptionType.connectionError) {
          return 'Problème de connexion internet';
        }
        return 'Une erreur s\'est produite';
    }
  }
}