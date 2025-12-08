import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_bloc.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_event.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_state.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/') {
      return 0;
    } else if (location == '/favorite') {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rick and Morty'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        actions: [
          // Кнопка переключения темы
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () {
                  context.read<ThemeBloc>().add(const ThemeToggleEvent());
                },
                icon: Icon(
                  state.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                  color: theme.colorScheme.onSurface,
                ),
              );
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/favorite');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Все персонажи',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Избранное'),
        ],
      ),
    );
  }
}
