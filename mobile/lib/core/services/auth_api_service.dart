// mobile/lib/core/services/auth_api_service.dart
import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../../shared/models/user.dart';
import '../../shared/models/auth_models.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import 'api_service.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService(this._apiService);

  Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    final response = await _apiService.dio.post(
      '/auth/login',
      data: {
        'identifier': request.identifier,
        'password': request.password,
        'rememberMe': request.rememberMe,
      },
    );

    return ApiResponse<AuthResponseData>(
      data: AuthResponseData.fromJson(response.data),
    );
  }

  Future<ApiResponse<AuthResponseData>> register(RegisterRequest request) async {
    final response = await _apiService.dio.post(
      '/auth/register',
      data: {
        'email': request.email,
        'password': request.password,
        'firstName': request.firstName,
        'lastName': request.lastName,
        'company': request.company,
        'position': request.position,
        'phone': request.phone,
        'acceptTerms': request.acceptTerms,
        'acceptMarketing': request.acceptMarketing,
      },
    );

    return ApiResponse<AuthResponseData>(
      data: AuthResponseData.fromJson(response.data),
    );
  }

  Future<ApiResponse<AuthResponseData>> socialLogin(SocialLoginRequest request) async {
    final response = await _apiService.dio.post(
      '/auth/social-login',
      data: request.toJson(),
    );

    return ApiResponse<AuthResponseData>(
      data: AuthResponseData.fromJson(response.data),
    );
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _apiService.dio.get('/auth/me');
    
    return ApiResponse<User>(
      data: User.fromJson(response.data['user'] ?? response.data),
    );
  }

  Future<ApiResponse<AuthResponseData>> refreshToken(RefreshTokenRequest request) async {
    final response = await _apiService.dio.post(
      '/auth/refresh',
      data: {'refreshToken': request.refreshToken},
    );

    return ApiResponse<AuthResponseData>(
      data: AuthResponseData.fromJson(response.data),
    );
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _apiService.dio.post('/auth/logout');
      return ApiResponse<void>.success(message: 'Déconnexion réussie');
    } on DioException {
      // Même si l'appel échoue, on considère la déconnexion comme réussie
      return ApiResponse<void>.success(message: 'Déconnexion réussie');
    }
  }

  Future<ApiResponse<AuthResponseData>> forgotPassword(ForgotPasswordRequest request) async {
    await _apiService.dio.post('/auth/forgot-password', data: request.toJson());
    return ApiResponse<AuthResponseData>.success(
      message: 'Email de réinitialisation envoyé',
    );
  }

  Future<ApiResponse<AuthResponseData>> resetPassword(ResetPasswordRequest request) async {
    await _apiService.dio.post('/auth/reset-password', data: request.toJson());
    return ApiResponse<AuthResponseData>.success(
      message: 'Mot de passe réinitialisé avec succès',
    );
  }

  Future<ApiResponse<void>> verifyEmail(String token) async {
    await _apiService.dio.post('/auth/verify-email', data: {'token': token});
    return ApiResponse<void>.success(message: 'Email vérifié avec succès');
  }

  Future<ApiResponse<void>> resendVerificationEmail() async {
    await _apiService.dio.post('/auth/resend-verification');
    return ApiResponse<void>.success(message: 'Email de vérification renvoyé');
  }

  Future<ApiResponse<void>> deleteAccount({required String password}) async {
    await _apiService.dio.delete('/auth/account', data: {'password': password});
    return ApiResponse<void>.success(message: 'Compte supprimé avec succès');
  }
}