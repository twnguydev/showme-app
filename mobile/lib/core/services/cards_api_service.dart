// mobile/lib/core/services/cards_api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:showme/shared/models/card.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class CardsApiService {
  final ApiService _apiService;

  CardsApiService(this._apiService);

  // Dans votre CardsApiService, ajoutez plus de debug
  Future<ApiResponse<List<Card>>> getBusinessCards() async {
    try {
      print('🔍 Récupération des cartes...');
      final response = await _apiService.dio.get('/cards');
      
      print('🔍 Statut de réponse: ${response.statusCode}');
      print('🔍 Type de données: ${response.data.runtimeType}');
      print('🔍 Données brutes: ${response.data}');
      
      // Vérifier la structure des données
      if (response.data is List) {
        final List<dynamic> cardsData = response.data;
        print('🔍 Nombre de cartes reçues: ${cardsData.length}');
        
        if (cardsData.isNotEmpty) {
          print('🔍 Première carte: ${cardsData.first}');
          
          // Tenter de parser chaque carte
          final cards = <Card>[];
          for (int i = 0; i < cardsData.length; i++) {
            try {
              final card = Card.fromJson(cardsData[i]);
              cards.add(card);
              print('✅ Carte $i parsée: ${card.title}');
            } catch (e) {
              print('❌ Erreur parsing carte $i: $e');
              print('❌ Données de la carte $i: ${cardsData[i]}');
            }
          }
          
          return ApiResponse<List<Card>>(data: cards);
        }
      } else if (response.data is Map && response.data.containsKey('data')) {
        // Si les données sont encapsulées dans un objet
        final List<dynamic> cardsData = response.data['data'];
        print('🔍 Cartes dans data: ${cardsData.length}');
        
        final cards = cardsData.map((cardJson) => Card.fromJson(cardJson)).toList();
        return ApiResponse<List<Card>>(data: cards);
      }
      
      print('❌ Structure de données inattendue');
      return ApiResponse<List<Card>>(data: []);
      
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.data}');
      throw e;
    } catch (e) {
      print('❌ Erreur générale: $e');
      throw e;
    }
  }

  Future<ApiResponse<Card>> getBusinessCard(String id) async {
    final response = await _apiService.dio.get('/cards/$id');
    
    return ApiResponse<Card>(
      data: Card.fromJson(response.data['data'] ?? response.data),
    );
  }

  Future<ApiResponse<Card>> getPublicBusinessCard(String id) async {
    final response = await _apiService.dio.get('/public/cards/$id');
    
    return ApiResponse<Card>(
      data: Card.fromJson(response.data['data'] ?? response.data),
    );
  }

  Future<ApiResponse<Card>> createBusinessCard(Map<String, dynamic> cardData) async {
    final response = await _apiService.dio.post('/cards', data: cardData);
    
    return ApiResponse<Card>(
      data: Card.fromJson(response.data['data'] ?? response.data),
    );
  }

  Future<ApiResponse<Card>> updateBusinessCard(String id, Map<String, dynamic> updateData) async {
    final response = await _apiService.dio.put('/cards/$id', data: updateData);
    
    return ApiResponse<Card>(
      data: Card.fromJson(response.data['data'] ?? response.data),
    );
  }

  Future<void> deleteBusinessCard(String id) async {
    await _apiService.dio.delete('/cards/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadCardImage(
    String cardId,
    File imageFile,
    String imageType,
  ) async {
    // Déterminer le type MIME du fichier
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    
    if (!mimeType.startsWith('image/')) {
      throw Exception('Le fichier sélectionné n\'est pas une image valide');
    }

    // Créer FormData pour l'upload multipart
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
      'type': imageType, // 'avatar', 'logo', 'background'
    });

    final response = await _apiService.dio.post(
      '/cards/$cardId/upload-image',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    return ApiResponse<Map<String, dynamic>>(
      data: response.data as Map<String, dynamic>,
    );
  }

  Future<Response> generateWalletPass(String id) async {
    return await _apiService.dio.get(
      '/cards/$id/wallet-pass',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/vnd.apple.pkpass',
        },
      ),
    );
  }
}