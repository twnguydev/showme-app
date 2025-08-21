// mobile/lib/features/card/bloc/card_state.dart
import 'package:equatable/equatable.dart';
import '../../../shared/models/card.dart';

abstract class CardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

// Load states
class CardLoaded extends CardState {
  final List<Card> cards;
  
  CardLoaded(this.cards);
  
  @override
  List<Object> get props => [cards];
}

class CardError extends CardState {
  final String message;
  
  CardError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Create states
class CardCreateLoading extends CardState {}

class CardCreateSuccess extends CardState {
  final Card card;
  final List<Card> allCards;
  
  CardCreateSuccess(this.card, this.allCards);
  
  @override
  List<Object> get props => [card, allCards];
}

// Update states
class CardUpdateLoading extends CardState {}

class CardUpdateSuccess extends CardState {
  final Card card;
  final List<Card> allCards;
  
  CardUpdateSuccess(this.card, this.allCards);
  
  @override
  List<Object> get props => [card, allCards];
}

// Delete states
class CardDeleteLoading extends CardState {}

class CardDeleteSuccess extends CardState {
  final List<Card> remainingCards;
  
  CardDeleteSuccess(this.remainingCards);
  
  @override
  List<Object> get props => [remainingCards];
}

// Share states
class CardShareLoading extends CardState {}

class CardShareSuccess extends CardState {
  final String shareUrl;
  final String message;
  
  CardShareSuccess(this.shareUrl, this.message);
  
  @override
  List<Object> get props => [shareUrl, message];
}

// Image upload states
class CardImageUploadLoading extends CardState {}

class CardImageUploadSuccess extends CardState {
  final String imageUrl;
  final String message;
  
  CardImageUploadSuccess(this.imageUrl, this.message);
  
  @override
  List<Object> get props => [imageUrl, message];
}

// Operation success states (for toggle, etc.)
class CardOperationSuccess extends CardState {
  final String message;
  final List<Card> cards;
  
  CardOperationSuccess(this.message, this.cards);
  
  @override
  List<Object> get props => [message, cards];
}