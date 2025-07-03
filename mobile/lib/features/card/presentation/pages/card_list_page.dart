// mobile/lib/features/card/presentation/pages/card_list_page.dart
import 'package:flutter/material.dart';

class CardListPage extends StatelessWidget {
  const CardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes cartes')),
      body: const Center(
        child: Text('Liste des cartes - En développement'),
      ),
    );
  }
}