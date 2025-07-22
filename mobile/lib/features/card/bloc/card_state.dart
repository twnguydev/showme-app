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
class CardLoadSuccess extends CardState {
  final List<Card> cards;
  
  CardLoadSuccess(this.cards);
  
  @override
  List<Object> get props => [cards];
}

class CardLoadError extends CardState {
  final String message;
  
  CardLoadError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Create states
class CardCreateLoading extends CardState {}

class CardCreateSuccess extends CardState {
  final Card card;
  
  CardCreateSuccess(this.card);
  
  @override
  List<Object> get props => [card];
}

class CardCreateError extends CardState {
  final String message;
  
  CardCreateError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Update states
class CardUpdateLoading extends CardState {}

class CardUpdateSuccess extends CardState {
  final Card card;
  
  CardUpdateSuccess(this.card);
  
  @override
  List<Object> get props => [card];
}

class CardUpdateError extends CardState {
  final String message;
  
  CardUpdateError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Delete states
class CardDeleteLoading extends CardState {}

class CardDeleteSuccess extends CardState {}

class CardDeleteError extends CardState {
  final String message;
  
  CardDeleteError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Share states
class CardShareLoading extends CardState {}

class CardShareSuccess extends CardState {
  final String shareUrl;
  
  CardShareSuccess(this.shareUrl);
  
  @override
  List<Object> get props => [shareUrl];
}

class CardShareError extends CardState {
  final String message;
  
  CardShareError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Image upload states
class CardImageUploadLoading extends CardState {}

class CardImageUploadSuccess extends CardState {
  final String imageUrl;
  
  CardImageUploadSuccess(this.imageUrl);
  
  @override
  List<Object> get props => [imageUrl];
}

class CardImageUploadError extends CardState {
  final String message;
  
  CardImageUploadError(this.message);
  
  @override
  List<Object> get props => [message];
}