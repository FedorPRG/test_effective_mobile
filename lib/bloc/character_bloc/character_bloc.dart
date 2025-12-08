import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_event.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_state.dart';
import 'package:test_effective_mobile/models/character.dart';
import 'package:test_effective_mobile/rest/rest.dart';
import 'package:test_effective_mobile/services/cache_service.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc()
    : super(
        CharacterChange(
          characters: [],
          currentPage: 1,
          hasMore: true,
          isLoading: false,
        ),
      ) {
    on<CharacterLoadEvent>(_onLoadCharacters);
    on<CharacterLoadMoreEvent>(_onLoadMoreCharacters);
    on<CharacterClickFavorite>(_clickFavorite);

    add(const CharacterLoadEvent());
  }

  Future<void> _onLoadCharacters(
    CharacterLoadEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final currentState = state as CharacterChange;

    if (currentState.isLoading) return;

    emit(currentState.copyWith(isLoading: true));

    try {
      // 1. Пытаемся загрузить из кеша
      if (await CacheService.hasPage(1)) {
        final cachedCharacters = await CacheService.getPage(1);

        emit(
          CharacterChange(
            characters: cachedCharacters,
            currentPage: 1,
            hasMore: true,
            isLoading: false,
          ),
        );
        log('✅ Первая страница загружена из кеша');
        return;
      }

      // 2. Если кеша нет - грузим из сети
      log('🌐 Кеша нет, грузим первую страницу из сети...');
      final apiResponse = await Rest.getCharacters(1);

      await CacheService.savePage(page: 1, characters: apiResponse.results);

      emit(
        CharacterChange(
          characters: apiResponse.results,
          currentPage: 1,
          hasMore: apiResponse.info.next != null,
          isLoading: false,
        ),
      );
      log('✅ Первая страница загружена из сети и сохранена в кеш');
    } catch (e) {
      log('❌ Ошибка загрузки первой страницы: $e');
      emit(currentState.copyWith(isLoading: false, hasMore: false));
    }
  }

  Future<void> _onLoadMoreCharacters(
    CharacterLoadMoreEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final currentState = state as CharacterChange;

    if (currentState.isLoading || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoading: true));

    try {
      final nextPage = currentState.currentPage + 1;

      // 1. Проверяем кеш
      if (await CacheService.hasPage(nextPage)) {
        final cachedCharacters = await CacheService.getPage(nextPage);
        final allCharacters = [...currentState.characters, ...cachedCharacters];

        emit(
          CharacterChange(
            characters: allCharacters,
            currentPage: nextPage,
            hasMore: true,
            isLoading: false,
          ),
        );
        log('✅ Страница $nextPage загружена из кеша');
      } else {
        // 2. Если кеша нет - грузим из сети
        log('🌐 Кеша страницы $nextPage нет, грузим из сети...');
        final apiResponse = await Rest.getCharacters(nextPage);

        await CacheService.savePage(
          page: nextPage,
          characters: apiResponse.results,
        );

        final allCharacters = [
          ...currentState.characters,
          ...apiResponse.results,
        ];

        emit(
          CharacterChange(
            characters: allCharacters,
            currentPage: nextPage,
            hasMore: apiResponse.info.next != null,
            isLoading: false,
          ),
        );
        log('✅ Страница $nextPage загружена из сети и сохранена в кеш');
      }
    } catch (e) {
      log('❌ Ошибка загрузки страницы: $e');
      emit(currentState.copyWith(isLoading: false));
    }
  }

  void _clickFavorite(
    CharacterClickFavorite event,
    Emitter<CharacterState> emit,
  ) {
    final currentState = state as CharacterChange;

    // Находим индекс персонажа в текущем списке
    final index = currentState.characters.indexWhere(
      (character) => character.id == event.idCharacter,
    );

    if (index != -1) {
      final character = currentState.characters[index];
      final updatedCharacter = character.copyWith(
        isFavorite: !character.isFavorite,
      );

      final updatedCharacters = List<Character>.from(currentState.characters);
      updatedCharacters[index] = updatedCharacter;

      // Сохраняем изменение в кеш
      // Нам нужно обновить кеш для всей страницы, где находится персонаж
      CacheService.updateFavoriteStatus(
        event.idCharacter,
        updatedCharacter.isFavorite,
      );

      emit(currentState.copyWith(characters: updatedCharacters));

      log('⭐ Избранное обновлено для ID: ${event.idCharacter}');
    }
  }
}
