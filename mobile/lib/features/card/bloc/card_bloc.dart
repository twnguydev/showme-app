// mobile/lib/features/card/bloc/card_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'card_event.dart';
import 'card_state.dart';
import '../../../core/services/cards_api_service.dart';
import '../../../features/auth/data/repositories/auth_repository.dart';
import '../../../shared/models/card.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final CardsApiService _cardsApiService;

  CardBloc({required CardsApiService cardsApiService})
      : _cardsApiService = cardsApiService,
        super(CardInitial()) {
    on<CardLoadRequested>(_onCardLoadRequested);
    on<CardCreateRequested>(_onCardCreateRequested);
    on<CardUpdateRequested>(_onCardUpdateRequested);
    on<CardDeleteRequested>(_onCardDeleteRequested);
    on<CardShareRequested>(_onCardShareRequested);
    on<CardQRGenerateRequested>(_onCardQRGenerateRequested);
    on<CardImageUploadRequested>(_onCardImageUploadRequested);
    on<CardRefreshRequested>(_onCardRefreshRequested);
    on<CardTogglePublicRequested>(_onCardTogglePublicRequested);
  }

  Future<void> _onCardLoadRequested(
    CardLoadRequested event,
    Emitter<CardState> emit,
  ) async {
    emit(CardLoading());

    try {
      final response = await _cardsApiService.getBusinessCards();
      emit(CardLoaded(response.data!));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors du chargement des cartes'));
    }
  }

  Future<void> _onCardCreateRequested(
    CardCreateRequested event,
    Emitter<CardState> emit,
  ) async {
    emit(CardCreateLoading());

    try {
      final response = await _cardsApiService.createBusinessCard(event.cardData);
      
      // Recharger toutes les cartes après création
      final cardsResponse = await _cardsApiService.getBusinessCards();
      emit(CardCreateSuccess(response.data!, cardsResponse.data!));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors de la création de la carte'));
    }
  }

  Future<void> _onCardUpdateRequested(
    CardUpdateRequested event,
    Emitter<CardState> emit,
  ) async {
    emit(CardUpdateLoading());

    try {
      final response = await _cardsApiService.updateBusinessCard(
        event.cardId, 
        event.updateData
      );
      
      // Recharger toutes les cartes après mise à jour
      final cardsResponse = await _cardsApiService.getBusinessCards();
      emit(CardUpdateSuccess(response.data!, cardsResponse.data!));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors de la mise à jour de la carte'));
    }
  }

  Future<void> _onCardDeleteRequested(
    CardDeleteRequested event,
    Emitter<CardState> emit,
  ) async {
    emit(CardDeleteLoading());

    try {
      await _cardsApiService.deleteBusinessCard(event.cardId);
      
      // Recharger toutes les cartes après suppression
      final cardsResponse = await _cardsApiService.getBusinessCards();
      emit(CardDeleteSuccess(cardsResponse.data!));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors de la suppression de la carte'));
    }
  }

  Future<void> _onCardShareRequested(
    CardShareRequested event,
    Emitter<CardState> emit,
  ) async {
    try {
      // Récupérer la carte pour obtenir son slug/URL
      final cardResponse = await _cardsApiService.getBusinessCard(event.cardId);
      final card = cardResponse.data!;
      
      // Construire l'URL de partage
      final shareUrl = 'https://votre-app.com/card/${card.slug}';
      
      emit(CardShareSuccess(shareUrl, 'Lien de partage généré'));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors de la génération du lien de partage'));
    }
  }

  Future<void> _onCardQRGenerateRequested(
    CardQRGenerateRequested event,
    Emitter<CardState> emit,
  ) async {
    try {
      // Récupérer la carte pour obtenir le QR code
      final cardResponse = await _cardsApiService.getBusinessCard(event.cardId);
      final card = cardResponse.data!;
      
      // Le QR code devrait être généré côté backend
      final qrCodeUrl = card.qrCodeUrl ?? 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://votre-app.com/card/${card.slug}';
      
      emit(CardShareSuccess(qrCodeUrl, 'QR Code généré'));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors de la génération du QR Code'));
    }
  }

  Future<void> _onCardImageUploadRequested(
    CardImageUploadRequested event,
    Emitter<CardState> emit,
  ) async {
    emit(CardImageUploadLoading());

    try {
      final response = await _cardsApiService.uploadCardImage(
        event.cardId,
        event.imageFile,
        event.imageType,
      );

      final imageUrl = response.data!['url'] as String;
      emit(CardImageUploadSuccess(imageUrl, 'Image uploadée avec succès'));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors de l\'upload de l\'image'));
    }
  }

  Future<void> _onCardRefreshRequested(
    CardRefreshRequested event,
    Emitter<CardState> emit,
  ) async {
    emit(CardLoading());

    try {
      final response = await _cardsApiService.getBusinessCards();
      emit(CardLoaded(response.data!));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors du rafraîchissement'));
    }
  }

  Future<void> _onCardTogglePublicRequested(
    CardTogglePublicRequested event,
    Emitter<CardState> emit,
  ) async {
    final currentState = state;
    List<Card> currentCards = [];
    
    if (currentState is CardLoaded) {
      currentCards = List.from(currentState.cards);
    }

    try {
      await _cardsApiService.updateBusinessCard(
        event.cardId,
        {'isPublic': event.isPublic}
      );

      final cardIndex = currentCards.indexWhere((card) => card.id.toString() == event.cardId);
      if (cardIndex != -1) {
        final updatedCard = currentCards[cardIndex].copyWith(isPublic: event.isPublic);
        currentCards[cardIndex] = updatedCard;
      }
      
      final message = event.isPublic 
          ? 'Carte rendue publique' 
          : 'Carte rendue privée';
      
      emit(CardOperationSuccess(message, currentCards));
    } on AuthException catch (e) {
      emit(CardError(e.message));
    } on DioException catch (e) {
      emit(CardError(_handleDioError(e)));
    } catch (e) {
      emit(CardError('Erreur lors du changement de visibilité'));
    }
  }

  /// Gère les erreurs DioException de manière centralisée
  String _handleDioError(DioException e) {
    print('🚨 CardBloc DioError: ${e.response?.data}');
    
    if (e.response?.data != null) {
      final data = e.response!.data;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') && data['message'] is List) {
          final messages = data['message'] as List;
          return messages.isNotEmpty 
            ? messages.first.toString() 
            : 'Erreur de validation';
        }
        
        if (data.containsKey('message') && data['message'] is String) {
          return data['message'] as String;
        }
        
        if (data.containsKey('error') && data['error'] is String) {
          return data['error'] as String;
        }
      }
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'Données invalides';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Vous n\'êtes pas autorisé à effectuer cette action';
      case 404:
        return 'Carte non trouvée';
      case 409:
        return 'Une carte avec ce nom existe déjà';
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

  // Méthodes utilitaires (si vous en avez besoin dans l'UI)
  List<Card> getPublicCards(List<Card> cards) {
    return cards.where((card) => card.isPublic).toList();
  }

  List<Card> getPrivateCards(List<Card> cards) {
    return cards.where((card) => !card.isPublic).toList();
  }

  int getTotalViews(List<Card> cards) {
    return cards.fold(0, (sum, card) => sum + card.viewsCount);
  }

  int getTotalShares(List<Card> cards) {
    return cards.fold(0, (sum, card) => sum + card.totalShared);
  }

  bool hasProCards(List<Card> cards) {
    return cards.any((card) => card.isPro);
  }
}