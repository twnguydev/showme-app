// mobile/lib/features/card/presentation/pages/card_form_page.dart
import 'package:flutter/material.dart';

class CardFormPage extends StatelessWidget {
  final String? cardId;
  
  const CardFormPage({super.key, this.cardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cardId == null ? 'Nouvelle carte' : 'Modifier la carte'),
      ),
      body: const Center(
        child: Text('Formulaire de carte - En développement'),
      ),
    );
  }
}