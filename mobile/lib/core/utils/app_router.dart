// mobile/lib/core/utils/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/card/presentation/pages/card_list_page.dart';
import '../../features/card/presentation/pages/card_detail_page.dart';
import '../../features/card/presentation/pages/card_form_page.dart';
import '../../features/card/presentation/pages/public_card_page.dart';
import '../../features/crm/presentation/pages/crm_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../shared/presentation/pages/home_page.dart';
import '../../shared/presentation/pages/nfc_share_page.dart';
import '../../shared/presentation/pages/paywall_page.dart';

class AppRouter {
  // Routes statiques pour être utilisées dans le main.dart
  static List<RouteBase> get routes => [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const NFCSharePage(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) {
        return PaywallPage(
          feature: state.uri.queryParameters['feature'],
          source: state.uri.queryParameters['source'],
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/cards',
      builder: (context, state) => const CardListPage(),
    ),
    GoRoute(
      path: '/cards/new',
      builder: (context, state) => const CardFormPage(),
    ),
    GoRoute(
      path: '/cards/:id',
      builder: (context, state) => CardDetailPage(
        cardId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/cards/:id/edit',
      builder: (context, state) => CardFormPage(
        cardId: state.pathParameters['id'],
      ),
    ),
    // Route publique pour les cartes partagées
    GoRoute(
      path: '/card/:id',
      builder: (context, state) => PublicCardPage(
        cardId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/crm',
      builder: (context, state) => const CrmPage(),
    ),
    GoRoute(
      path: '/payment/:cardId',
      builder: (context, state) => PaymentPage(
        cardId: state.pathParameters['cardId']!,
      ),
    ),
  ];

  // Router original (gardé pour compatibilité si nécessaire)
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: routes,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page non trouvée: ${state.uri.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}