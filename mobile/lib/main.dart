// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_router.dart';
import '../../core/utils/app_theme.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/card/bloc/card_bloc.dart';
import '../../features/crm/bloc/crm_bloc.dart';
import '../../features/profile/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive pour le stockage local
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
                
                // CardBloc avec ApiService
                BlocProvider<CardBloc>(
                  create: (context) => CardBloc(),
                ),
                
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
              child: MaterialApp.router(
                title: 'Showme',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                routerConfig: AppRouter.router,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  // Optionnel: pour intercepter les erreurs globalement
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: child!,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}