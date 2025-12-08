import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_event.dart';
import 'package:test_effective_mobile/bloc/theme_bloc/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'isDarkTheme';

  ThemeBloc() : super(const ThemeState(isDarkTheme: false)) {
    on<ThemeToggleEvent>(_onToggleTheme);
    on<ThemeLoadEvent>(_onLoadTheme);

    // Загружаем сохраненную тему при запуске
    add(const ThemeLoadEvent());
  }

  Future<void> _onToggleTheme(
    ThemeToggleEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newThemeState = ThemeState(isDarkTheme: !state.isDarkTheme);
    emit(newThemeState);

    // Сохраняем в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newThemeState.isDarkTheme);
  }

  Future<void> _onLoadTheme(
    ThemeLoadEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkTheme = prefs.getBool(_themeKey) ?? false;
    emit(ThemeState(isDarkTheme: isDarkTheme));
  }
}
