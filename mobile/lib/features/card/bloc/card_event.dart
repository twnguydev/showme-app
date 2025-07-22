// mobile/lib/features/card/bloc/card_event.dart
import 'dart:io';

abstract class CardEvent {}

class CardLoadRequested extends CardEvent {}

class CardCreateRequested extends CardEvent {
  final Map<String, dynamic> cardData;
  
  CardCreateRequested(this.cardData);
}

class CardUpdateRequested extends CardEvent {
  final String cardId;
  final Map<String, dynamic> updateData;
  
  CardUpdateRequested(this.cardId, this.updateData);
}

class CardDeleteRequested extends CardEvent {
  final String cardId;
  
  CardDeleteRequested(this.cardId);
}

class CardShareRequested extends CardEvent {
  final String cardId;
  final String method;
  
  CardShareRequested(this.cardId, this.method);
}

class CardQRGenerateRequested extends CardEvent {
  final String cardId;
  
  CardQRGenerateRequested(this.cardId);
}

class CardImageUploadRequested extends CardEvent {
  final String cardId;
  final File imageFile;
  final String imageType; // 'avatar', 'logo', 'background'
  
  CardImageUploadRequested(this.cardId, this.imageFile, this.imageType);
}