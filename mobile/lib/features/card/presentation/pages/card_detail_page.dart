// mobile/lib/features/card/presentation/pages/card_detail_page.dart
import 'package:flutter/material.dart';

class CardDetailPage extends StatelessWidget {
  final String cardId;
  
  const CardDetailPage({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la carte')),
      body: Center(
        child: Text('Détail de la carte $cardId - En développement'),
      ),
    );
  }
}