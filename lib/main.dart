import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_bloc.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_bloc.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_state.dart';
import 'package:test_effective_mobile/data/contracts/api_client.dart';
import 'package:test_effective_mobile/data/contracts/local_cache.dart';
import 'package:test_effective_mobile/data/repositories/character_repository.dart';
import 'package:test_effective_mobile/data/services/rest_api_client.dart';
import 'package:test_effective_mobile/data/services/shared_prefs_cache.dart';
import 'package:test_effective_mobile/router_config/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>(create: (context) => RestApiClient()),
        RepositoryProvider<LocalCache>(create: (context) => SharedPrefsCache()),
        RepositoryProvider<CharacterRepository>(
          create: (context) => CharacterRepository(
            apiClient: context.read<ApiClient>(),
            localCache: context.read<LocalCache>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                CharacterBloc(repository: context.read<CharacterRepository>()),
          ),
          BlocProvider(create: (context) => ThemeBloc()),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: RoutesConfig.router,
              theme: themeState.themeData,
            );
          },
        ),
      ),
    );
  }
}
