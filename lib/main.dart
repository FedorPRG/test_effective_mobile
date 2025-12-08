import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/bloc.dart';
import 'package:test_effective_mobile/router_config/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CharacterBloc(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: RoutesConfig.router,
      ),
    );
  }
}
