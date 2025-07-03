// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/utils/app_router.dart';
import 'core/utils/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/card/bloc/card_bloc.dart';
import 'features/crm/bloc/crm_bloc.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(
            apiService: ApiService(),
            storageService: StorageService(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => CardBloc(),
          ),
          BlocProvider(
            create: (context) => CrmBloc(),
          ),
        ],
        child: MaterialApp.router(
          title: 'Showme',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}