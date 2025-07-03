// mobile/lib/features/card/bloc/card_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/models/card.dart';
import '../../../shared/models/profile.dart';

// Events
abstract class CardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CardLoadRequested extends CardEvent {}

class CardCreateRequested extends CardEvent {
  final Map<String, dynamic> cardData;
  
  CardCreateRequested(this.cardData);
  
  @override
  List<Object> get props => [cardData];
}

class CardUpdateRequested extends CardEvent {
  final String cardId;
  final Map<String, dynamic> cardData;
  
  CardUpdateRequested(this.cardId, this.cardData);
  
  @override
  List<Object> get props => [cardId, cardData];
}

class CardDeleteRequested extends CardEvent {
  final String cardId;
  
  CardDeleteRequested(this.cardId);
  
  @override
  List<Object> get props => [cardId];
}

class CardRefreshRequested extends CardEvent {}

class CardTogglePublicRequested extends CardEvent {
  final String cardId;
  final bool isPublic;
  
  CardTogglePublicRequested(this.cardId, this.isPublic);
  
  @override
  List<Object> get props => [cardId, isPublic];
}

// States
abstract class CardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final List<Card> cards;
  
  CardLoaded(this.cards);
  
  @override
  List<Object> get props => [cards];
}

class CardOperationSuccess extends CardState {
  final String message;
  final List<Card> cards;
  
  CardOperationSuccess(this.message, this.cards);
  
  @override
  List<Object> get props => [message, cards];
}

class CardError extends CardState {
  final String message;
  
  CardError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Bloc
class CardBloc extends Bloc<CardEvent, CardState> {
  final List<Card> _cards = [];

  CardBloc() : super(CardInitial()) {
    on<CardLoadRequested>(_onLoadRequested);
    on<CardCreateRequested>(_onCreateRequested);
    on<CardUpdateRequested>(_onUpdateRequested);
    on<CardDeleteRequested>(_onDeleteRequested);
    on<CardRefreshRequested>(_onRefreshRequested);
    on<CardTogglePublicRequested>(_onTogglePublicRequested);
  }

  Future<void> _onLoadRequested(
    CardLoadRequested event,
    Emitter<CardState> emit,
  ) async {
    emit(CardLoading());
    
    try {
      // Simulation avec une carte de démo
      await Future.delayed(const Duration(milliseconds: 500));
      final demoCard = Card.demo();
      _cards.clear();
      _cards.add(demoCard);
      emit(CardLoaded(List.from(_cards)));
    } catch (e) {
      emit(CardError('Erreur lors du chargement des cartes: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRequested(
    CardCreateRequested event,
    Emitter<CardState> emit,
  ) async {
    try {
      emit(CardLoading());
      
      // Simulation de création
      await Future.delayed(const Duration(seconds: 1));
      
      // Créer une nouvelle carte avec les données fournies
      final newCard = Card(
        id: DateTime.now().millisecondsSinceEpoch,
        slug: event.cardData['slug'] ?? 'new-card-${_cards.length + 1}',
        title: event.cardData['title'] ?? 'Nouvelle carte',
        bio: event.cardData['bio'],
        isPublic: event.cardData['isPublic'] ?? true,
        viewsCount: 0,
        walletPassUrl: null,
        allowPayment: event.cardData['allowPayment'] ?? false,
        nfcEnabled: event.cardData['nfcEnabled'] ?? false,
        qrCodeUrl: null,
        totalShared: 0,
        totalLeads: 0,
        profile: Profile.demo(), // Utiliser un profil par défaut
        subscription: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _cards.add(newCard);
      emit(CardOperationSuccess('Carte créée avec succès', List.from(_cards)));
    } catch (e) {
      emit(CardError('Erreur lors de la création de la carte: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRequested(
    CardUpdateRequested event,
    Emitter<CardState> emit,
  ) async {
    try {
      emit(CardLoading());
      
      // Simulation de mise à jour
      await Future.delayed(const Duration(seconds: 1));
      
      final cardIndex = _cards.indexWhere((card) => card.id.toString() == event.cardId);
      if (cardIndex != -1) {
        final existingCard = _cards[cardIndex];
        final updatedCard = existingCard.copyWith(
          title: event.cardData['title'],
          bio: event.cardData['bio'],
          isPublic: event.cardData['isPublic'],
          allowPayment: event.cardData['allowPayment'],
          nfcEnabled: event.cardData['nfcEnabled'],
        );
        
        _cards[cardIndex] = updatedCard;
        emit(CardOperationSuccess('Carte mise à jour avec succès', List.from(_cards)));
      } else {
        emit(CardError('Carte non trouvée'));
      }
    } catch (e) {
      emit(CardError('Erreur lors de la mise à jour de la carte: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRequested(
    CardDeleteRequested event,
    Emitter<CardState> emit,
  ) async {
    try {
      emit(CardLoading());
      
      // Simulation de suppression
      await Future.delayed(const Duration(milliseconds: 500));
      
      final cardIndex = _cards.indexWhere((card) => card.id.toString() == event.cardId);
      if (cardIndex != -1) {
        _cards.removeAt(cardIndex);
        emit(CardOperationSuccess('Carte supprimée avec succès', List.from(_cards)));
      } else {
        emit(CardError('Carte non trouvée'));
      }
    } catch (e) {
      emit(CardError('Erreur lors de la suppression de la carte: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRequested(
    CardRefreshRequested event,
    Emitter<CardState> emit,
  ) async {
    try {
      emit(CardLoading());
      
      // Simulation de rafraîchissement
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mettre à jour les statistiques des cartes existantes
      for (int i = 0; i < _cards.length; i++) {
        final card = _cards[i];
        final updatedCard = card.copyWith(
          viewsCount: card.viewsCount + (1 + (i * 2)), // Simulation d'augmentation des vues
          totalShared: card.totalShared + 1,
        );
        _cards[i] = updatedCard;
      }
      
      emit(CardLoaded(List.from(_cards)));
    } catch (e) {
      emit(CardError('Erreur lors du rafraîchissement: ${e.toString()}'));
    }
  }

  Future<void> _onTogglePublicRequested(
    CardTogglePublicRequested event,
    Emitter<CardState> emit,
  ) async {
    try {
      emit(CardLoading());
      
      // Simulation de changement de visibilité
      await Future.delayed(const Duration(milliseconds: 300));
      
      final cardIndex = _cards.indexWhere((card) => card.id.toString() == event.cardId);
      if (cardIndex != -1) {
        final existingCard = _cards[cardIndex];
        final updatedCard = existingCard.copyWith(
          isPublic: event.isPublic,
        );
        
        _cards[cardIndex] = updatedCard;
        final message = event.isPublic 
            ? 'Carte rendue publique' 
            : 'Carte rendue privée';
        emit(CardOperationSuccess(message, List.from(_cards)));
      } else {
        emit(CardError('Carte non trouvée'));
      }
    } catch (e) {
      emit(CardError('Erreur lors du changement de visibilité: ${e.toString()}'));
    }
  }

  // Méthodes utilitaires
  Card? getCardById(String cardId) {
    try {
      return _cards.firstWhere((card) => card.id.toString() == cardId);
    } catch (e) {
      return null;
    }
  }

  List<Card> getPublicCards() {
    return _cards.where((card) => card.isPublic).toList();
  }

  List<Card> getPrivateCards() {
    return _cards.where((card) => !card.isPublic).toList();
  }

  int getTotalViews() {
    return _cards.fold(0, (sum, card) => sum + card.viewsCount);
  }

  int getTotalShares() {
    return _cards.fold(0, (sum, card) => sum + card.totalShared);
  }

  bool hasProCards() {
    return _cards.any((card) => card.isPro);
  }
}