// mobile/lib/features/card/bloc/card_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';

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
  final Map<String, dynamic> updateData;
  
  CardUpdateRequested(this.cardId, this.updateData);
  
  @override
  List<Object> get props => [cardId, updateData];
}

class CardDeleteRequested extends CardEvent {
  final String cardId;
  
  CardDeleteRequested(this.cardId);
  
  @override
  List<Object> get props => [cardId];
}

class CardShareRequested extends CardEvent {
  final String cardId;
  final String method;
  
  CardShareRequested(this.cardId, this.method);
  
  @override
  List<Object> get props => [cardId, method];
}

class CardQRGenerateRequested extends CardEvent {
  final String cardId;
  
  CardQRGenerateRequested(this.cardId);
  
  @override
  List<Object> get props => [cardId];
}

class CardImageUploadRequested extends CardEvent {
  final String cardId;
  final File imageFile;
  final String imageType; // 'avatar', 'logo', 'background'
  
  CardImageUploadRequested(this.cardId, this.imageFile, this.imageType);
  
  @override
  List<Object> get props => [cardId, imageFile, imageType];
}

class CardRefreshRequested extends CardEvent {}

class CardTogglePublicRequested extends CardEvent {
  final String cardId;
  final bool isPublic;
  
  CardTogglePublicRequested(this.cardId, this.isPublic);
  
  @override
  List<Object> get props => [cardId, isPublic];
}