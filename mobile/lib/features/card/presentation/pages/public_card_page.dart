// mobile/lib/features/card/presentation/pages/public_card_page.dart
import 'package:flutter/material.dart';

class PublicCardPage extends StatelessWidget {
  final String cardId;
  
  const PublicCardPage({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte de visite')),
      body: Center(
        child: Text('Carte publique $cardId - En développement'),
      ),
    );
  }
}