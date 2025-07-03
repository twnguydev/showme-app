// mobile/lib/features/payment/presentation/pages/payment_page.dart
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String cardId;
  
  const PaymentPage({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Center(
        child: Text('Page de paiement pour $cardId - En développement'),
      ),
    );
  }
}