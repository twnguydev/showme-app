// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/app_router.dart';
import 'core/utils/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/card/bloc/card_bloc.dart';
import 'features/crm/bloc/crm_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await StorageService.init();
  
  runApp(const ShowmeApp());
}

class ShowmeApp extends StatelessWidget {
  const ShowmeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, apiService) => apiService.dispose(),
        ),
        
        // StorageService en provider si nécessaire
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Maintenant on peut accéder aux services via context.read
          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider<AuthRepository>(
                create: (context) => AuthRepository(
                  apiService: context.read<ApiService>(),
                  storageService: context.read<StorageService>(),
                ),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                // AuthBloc
                BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                    authRepository: context.read<AuthRepository>(),
                  )..add(AuthCheckRequested()),
                ),

                BlocProvider<CardBloc>(create: (context) => CardBloc()),
                
                // CrmBloc avec ApiService  
                BlocProvider<CrmBloc>(
                  create: (context) => CrmBloc(),
                ),
                
                // ProfileBloc en provider global
                BlocProvider<ProfileBloc>(
                  create: (context) => ProfileBloc(
                    apiService: context.read<ApiService>(),
                  ),
                ),
              ],
              child: ShowmeAppRouter(),
            ),
          );
        },
      ),
    );
  }
}

// Widget séparé pour gérer le router avec AuthBloc
class ShowmeAppRouter extends StatefulWidget {
  @override
  State<ShowmeAppRouter> createState() => _ShowmeAppRouterState();
}

class _ShowmeAppRouterState extends State<ShowmeAppRouter> {
  late final GoRouter _router;
  late final StreamSubscription _authSubscription;

  @override
  void initState() {
    super.initState();
    
    // Configurer le callback pour les erreurs 401
    ApiService.setUnauthorizedCallback(() {
      if (mounted) {
        context.read<AuthBloc>().add(AuthTokenExpired());
      }
    });
    
    // Créer le router avec gestion d'authentification
    _router = _createRouter();
    
    // Écouter les changements d'état d'authentification pour forcer le refresh du router
    _authSubscription = context.read<AuthBloc>().stream.listen((state) {
      if (mounted) {
        _router.refresh();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/home',
      redirect: (context, state) {
        // Obtenir l'état d'authentification actuel
        final authState = context.read<AuthBloc>().state;
        final isLoggedIn = authState is AuthAuthenticated;
        
        // Pages publiques qui ne nécessitent pas d'authentification
        final publicPaths = ['/splash', '/login', '/register'];
        final isPublicPath = publicPaths.contains(state.fullPath) || 
                           state.fullPath?.startsWith('/card/') == true;
        
        // Logs pour le debugging
        debugPrint('🔄 Router redirect - Location: ${state.fullPath}, Authenticated: $isLoggedIn');
        
        // Si pas connecté et pas sur une page publique
        if (!isLoggedIn && !isPublicPath) {
          debugPrint('🔐 Redirection vers login - utilisateur non authentifié');
          return '/login';
        }
        
        // Si connecté et sur login/register
        if (isLoggedIn && (state.fullPath == '/login' || state.fullPath == '/register')) {
          debugPrint('🏠 Redirection vers home - utilisateur déjà connecté');
          return '/home';
        }
        
        // Pas de redirection nécessaire
        return null;
      },
      routes: AppRouter.routes,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Gérer les changements d'état d'authentification
        if (state is AuthUnauthenticated) {
          debugPrint('🔄 Utilisateur déconnecté - Le router va rediriger vers login');
        } else if (state is AuthAuthenticated) {
          debugPrint('🔄 Utilisateur connecté - Le router va rediriger vers home');
        } else if (state is AuthError) {
          debugPrint('❌ Erreur d\'authentification: ${state.message}');
          // Optionnel: Afficher un snackbar ou une notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: MaterialApp.router(
        title: 'Showme',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Pour intercepter les erreurs globalement et fixer le text scale
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}