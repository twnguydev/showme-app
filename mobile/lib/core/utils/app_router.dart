// mobile/lib/core/utils/app_router.dart (CORRIGÉ)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/card/presentation/pages/card_list_page.dart';
import '../../features/card/presentation/pages/card_detail_page.dart';
import '../../features/card/presentation/pages/card_form_page.dart';
import '../../features/card/presentation/pages/public_card_page.dart';
import '../../features/crm/presentation/pages/crm_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../shared/presentation/pages/home_page.dart';
import '../../shared/presentation/pages/splash_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      
      // Pages publiques
      final publicPaths = ['/splash', '/login', '/register', '/card'];
      final isPublicPath = publicPaths.any((path) => state.fullPath?.startsWith(path) == true);
      
      // Si pas connecté et pas sur une page publique
      if (!isLoggedIn && !isPublicPath) {
        return '/login';
      }
      
      // Si connecté et sur login/register
      if (isLoggedIn && (state.fullPath == '/login' || state.fullPath == '/register')) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
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
      GoRoute(
        path: '/card/:id',
        builder: (context, state) => PublicCardPage(
          cardId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/sharing',
        builder: (context, state) => const SharingPageStub(),
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
    ],
  );
}

// Page temporaire pour éviter l'erreur de compilation
class SharingPageStub extends StatelessWidget {
  const SharingPageStub({super.key});

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