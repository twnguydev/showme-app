// mobile/lib/features/sharing/presentation/pages/sharing_page.dart
import 'package:flutter/material.dart';

class SharingPage extends StatelessWidget {
  const SharingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partager ma carte')),
      body: const Center(
        child: Text('Page de partage - En développement'),
      ),
    );
  }
}