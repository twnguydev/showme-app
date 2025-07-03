// mobile/lib/features/crm/presentation/pages/crm_page.dart
import 'package:flutter/material.dart';

class CrmPage extends StatelessWidget {
  const CrmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes contacts')),
      body: const Center(
        child: Text('Mini CRM - En développement'),
      ),
    );
  }
}