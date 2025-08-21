// mobile/lib/core/services/users_api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/api_response.dart';
import '../../shared/models/user.dart';
import 'api_service.dart';

class UsersApiService {
  final ApiService _apiService;

  UsersApiService(this._apiService);

  Future<ApiResponse<User>> updateProfile(Map<String, dynamic> updateData) async {
    final response = await _apiService.dio.put(
      '/users/me',
      data: updateData,
    );

    return ApiResponse<User>(
      data: User.fromJson(response.data['user'] ?? response.data),
    );
  }

  Future<ApiResponse<dynamic>> updateDetailedProfile(Map<String, dynamic> updateData) async {
    final response = await _apiService.dio.put(
      '/users/me/profile',
      data: updateData,
    );

    return ApiResponse<dynamic>(
      data: response.data,
    );
  }

  /// Upload d'avatar avec rafraîchissement automatique de l'utilisateur
  Future<ApiResponse<User>> uploadAvatar(File imageFile) async {
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    print('Uploading file with MIME type: $mimeType');
    
    if (!mimeType.startsWith('image/')) {
      throw Exception('Le fichier sélectionné n\'est pas une image valide');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
    });

    print('Uploading file: ${imageFile.path}');
    print('File size: ${await imageFile.length()} bytes');

    // Upload de l'avatar
    final uploadResponse = await _apiService.dio.put(
      '/users/me/avatar',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    print('Upload response: ${uploadResponse.data}');

    // Récupérer l'utilisateur mis à jour
    final userResponse = await _apiService.dio.get('/auth/me');
    
    return ApiResponse<User>(
      data: User.fromJson(userResponse.data['user'] ?? userResponse.data),
      message: 'Avatar mis à jour avec succès',
    );
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiService.dio.put('/users/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    
    return ApiResponse<void>.success(
      message: 'Mot de passe modifié avec succès',
    );
  }
}