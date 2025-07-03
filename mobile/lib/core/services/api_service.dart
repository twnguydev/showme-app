// // mobile/lib/core/services/api_service.dart
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:retrofit/retrofit.dart';
// import 'package:json_annotation/json_annotation.dart';

// import '../config/app_config.dart';
// import '../models/api_response.dart';
// import '../../shared/models/user.dart';
// import '../../shared/models/business_card.dart';
// import '../../shared/models/contact_exchange.dart';
// import '../../shared/models/payment.dart';

// part 'api_service.g.dart';

// @RestApi(baseUrl: AppConfig.apiUrl)
// abstract class ApiService {
//   factory ApiService([Dio? dio]) {
//     dio ??= Dio();
    
//     // Configuration des interceptors
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           // Ajouter le token d'authentification
//           final token = StorageService.getToken();
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           handler.next(options);
//         },
//         onError: (error, handler) {
//           // Gestion globale des erreurs
//           if (error.response?.statusCode == 401) {
//             // Token expiré, rediriger vers la connexion
//             StorageService.clearToken();
//           }
//           handler.next(error);
//         },
//       ),
//     );
    
//     return _ApiService(dio);
//   }

//   // Auth endpoints
//   @POST('/auth/local')
//   Future<ApiResponse<AuthResponse>> login(@Body() LoginRequest request);

//   @POST('/auth/local/register')
//   Future<ApiResponse<AuthResponse>> register(@Body() RegisterRequest request);

//   @GET('/users/me')
//   Future<ApiResponse<User>> getCurrentUser();

//   // Business Cards endpoints
//   @GET('/business-cards')
//   Future<ApiResponse<List<BusinessCard>>> getBusinessCards();

//   @GET('/business-cards/{id}')
//   Future<ApiResponse<BusinessCard>> getBusinessCard(@Path() String id);

//   @GET('/business-cards/{id}/public')
//   Future<ApiResponse<BusinessCard>> getPublicBusinessCard(@Path() String id);

//   @POST('/business-cards')
//   Future<ApiResponse<BusinessCard>> createBusinessCard(@Body() CreateBusinessCardRequest request);

//   @PUT('/business-cards/{id}')
//   Future<ApiResponse<BusinessCard>> updateBusinessCard(
//     @Path() String id,
//     @Body() UpdateBusinessCardRequest request,
//   );

//   @DELETE('/business-cards/{id}')
//   Future<void> deleteBusinessCard(@Path() String id);

//   @GET('/business-cards/{id}/wallet-pass')
//   Future<Response> generateWalletPass(@Path() String id);

//   // Contact Exchanges endpoints
//   @GET('/contact-exchanges')
//   Future<ApiResponse<List<ContactExchange>>> getContactExchanges();

//   @POST('/contact-exchanges')
//   Future<ApiResponse<ContactExchange>> createContactExchange(@Body() CreateContactExchangeRequest request);

//   @GET('/contact-exchanges/stats')
//   Future<ApiResponse<ContactStats>> getContactStats();

//   // Payments endpoints
//   @GET('/payments')
//   Future<ApiResponse<List<Payment>>> getPayments();

//   @POST('/payments/create-intent')
//   Future<ApiResponse<PaymentIntentResponse>> createPaymentIntent(@Body() CreatePaymentIntentRequest request);

//   // File upload
//   @POST('/upload')
//   @MultiPart()
//   Future<ApiResponse<List<UploadedFile>>> uploadFiles(@Part() List<File> files);
// }

// mobile/lib/core/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../models/api_response.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/user.dart';
import '../../shared/models/card.dart'; // Changed from business_card.dart to card.dart
import '../../shared/models/contact_exchange.dart';
import '../../shared/models/contact_stats.dart'; // Added missing import
import '../../shared/models/auth_models.dart'; // Added auth models
import '../../features/auth/data/repositories/auth_repository.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio();
    
    // Configuration de base
    _dio.options.baseUrl = AppConfig.apiUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ajouter le token d'authentification
          final token = StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) {
          // Gestion globale des erreurs
          if (error.response?.statusCode == 401) {
            // Token expiré, rediriger vers la connexion
            StorageService.clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  // Auth endpoints (simulation pour le développement)
  Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    // Simulation de l'appel API
    await Future.delayed(const Duration(seconds: 1));
    
    if (request.identifier == 'demo@showme.com' && request.password == 'password') {
      final user = User(
        id: 1,
        username: request.identifier,
        email: request.identifier,
        firstName: 'Jean',
        lastName: 'Dupont',
        company: 'Showme Corp',
        position: 'Consultant Senior',
        phoneNumber: '+33 6 12 34 56 78',
        linkedinUrl: 'https://linkedin.com/in/exemple',
        website: 'https://exemple.com',
        profilePicture: null,
        isActive: true,
        lastLoginAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final authData = AuthResponseData(
        jwt: 'demo_jwt_token_123',
        user: user,
      );
      
      return ApiResponse<AuthResponseData>(data: authData);
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );
    }
  }

  Future<ApiResponse<AuthResponseData>> register(RegisterRequest request) async {
    // Simulation de l'appel API
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch,
      username: request.email,
      email: request.email,
      firstName: request.firstName,
      lastName: request.lastName,
      company: request.company,
      position: request.position,
      phoneNumber: null,
      linkedinUrl: null,
      website: null,
      profilePicture: null,
      isActive: true,
      lastLoginAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final authData = AuthResponseData(
      jwt: 'demo_jwt_token_456',
      user: user,
    );
    
    return ApiResponse<AuthResponseData>(data: authData);
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    // Simulation - récupérer depuis le storage local
    final userData = StorageService.getUser();
    if (userData != null) {
      return ApiResponse<User>(data: User.fromJson(userData));
    }
    
    throw DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 401,
      ),
    );
  }

  // Business Cards endpoints (simulation) - Updated to use Card instead of BusinessCard
  Future<ApiResponse<List<Card>>> getBusinessCards() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse<List<Card>>(data: [Card.demo()]);
  }

  Future<ApiResponse<Card>> getBusinessCard(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse<Card>(data: Card.demo());
  }

  Future<ApiResponse<Card>> getPublicBusinessCard(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse<Card>(data: Card.demo());
  }

  // Méthodes futures pour les autres endpoints
  Future<ApiResponse<Card>> createBusinessCard(Map<String, dynamic> request) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse<Card>(data: Card.demo());
  }

  Future<ApiResponse<Card>> updateBusinessCard(String id, Map<String, dynamic> request) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse<Card>(data: Card.demo());
  }

  Future<void> deleteBusinessCard(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Response> generateWalletPass(String id) async {
    await Future.delayed(const Duration(seconds: 2));
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
    );
  }

  Future<ApiResponse<List<ContactExchange>>> getContactExchanges() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse<List<ContactExchange>>(data: []);
  }

  Future<ApiResponse<ContactExchange>> createContactExchange(Map<String, dynamic> request) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final exchange = ContactExchange(
      id: DateTime.now().millisecondsSinceEpoch,
      timestamp: DateTime.now(),
      geoLocation: request['location'],
      userAgent: request['userAgent'],
      referrer: ExchangeMethod.values.firstWhere(
        (e) => e.toString().split('.').last == (request['method'] ?? 'link').toLowerCase(),
        orElse: () => ExchangeMethod.link,
      ),
      openedOnWallet: false,
      contactAdded: false,
      emailSubmitted: request['receiverEmail'],
      deviceType: DeviceType.unknown,
      card: Card.demo(),
      visitor: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return ApiResponse<ContactExchange>(data: exchange);
  }

  Future<ApiResponse<ContactStats>> getContactStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final stats = ContactStats.demo();
    return ApiResponse<ContactStats>(data: stats);
  }

  // Méthodes d'authentification additionnelles
  Future<ApiResponse<AuthResponseData>> forgotPassword(ForgotPasswordRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulation - dans la vraie vie, cela enverrait un email
    return ApiResponse<AuthResponseData>.success(
      message: 'Email de réinitialisation envoyé',
    );
  }

  Future<ApiResponse<AuthResponseData>> resetPassword(ResetPasswordRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulation de réinitialisation
    if (request.passwordsMatch) {
      return ApiResponse<AuthResponseData>.success(
        message: 'Mot de passe réinitialisé avec succès',
      );
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Les mots de passe ne correspondent pas'},
        ),
      );
    }
  }

  Future<ApiResponse<AuthResponseData>> refreshToken(RefreshTokenRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulation - générer un nouveau token
    final user = User.demo();
    final authData = AuthResponseData(
      jwt: 'refreshed_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      refreshToken: 'new_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    return ApiResponse<AuthResponseData>(data: authData);
  }

  Future<ApiResponse<void>> verifyEmail(String token) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse<void>.success(
      message: 'Email vérifié avec succès',
    );
  }

  Future<ApiResponse<void>> resendVerificationEmail() async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse<void>.success(
      message: 'Email de vérification renvoyé',
    );
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse<void>.success(
      message: 'Mot de passe modifié avec succès',
    );
  }

  Future<ApiResponse<void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ApiResponse<void>.success(
      message: 'Déconnexion réussie',
    );
  }

  Future<ApiResponse<void>> deleteAccount({required String password}) async {
    await Future.delayed(const Duration(seconds: 2));
    return ApiResponse<void>.success(
      message: 'Compte supprimé avec succès',
    );
  }

  Future<ApiResponse<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? company,
    String? position,
    String? phoneNumber,
    String? website,
    String? linkedinUrl,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulation - récupérer l'utilisateur actuel et le mettre à jour
    final currentUser = User.demo();
    final updatedUser = currentUser.copyWith(
      firstName: firstName,
      lastName: lastName,
      company: company,
      position: position,
      phoneNumber: phoneNumber,
      website: website,
      linkedinUrl: linkedinUrl,
    );
    
    return ApiResponse<User>(data: updatedUser);
  }
}