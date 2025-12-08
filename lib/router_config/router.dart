import 'package:go_router/go_router.dart';
import 'package:test_effective_mobile/views/all_characters.dart';
import 'package:test_effective_mobile/views/favorites.dart';
import 'package:test_effective_mobile/views/main_screen.dart';

class RoutesConfig {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: const AllCharacters());
            },
          ),
          GoRoute(
            path: '/favorite',
            pageBuilder: (context, state) {
              return NoTransitionPage(child: const Favorites());
            },
          ),
        ],
      ),
    ],
  );
}
