import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_bloc.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_bloc.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_state.dart';
import 'package:test_effective_mobile/router_config/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CharacterBloc()),
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
    );
  }
}
