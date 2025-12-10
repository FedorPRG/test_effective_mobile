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
        const CharacterState(
          characters: [],
          favoriteCharacters: [],
          currentPage: 1,
          hasMore: true,
          isLoading: false,
          isFavoritesLoading: false,
        ),
      ) {
    on<CharacterLoadEvent>(_onLoadCharacters);
    on<CharacterLoadMoreEvent>(_onLoadMoreCharacters);
    on<CharacterClickFavorite>(_onClickFavorite);
    on<FavoritesLoadEvent>(_onLoadFavorites);
    on<FavoriteRemoveEvent>(_onRemoveFavorite);

    add(const CharacterLoadEvent());
  }

  // ========== ГЛАВНЫЙ ЭКРАН ==========

  Future<void> _onLoadCharacters(
    CharacterLoadEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    try {
      if (await CacheService.hasPage(1)) {
        final cachedCharacters = await CacheService.getPage(1);
        final updatedCharacters = await _updateFavoritesStatus(
          cachedCharacters,
        );

        emit(
          state.copyWith(
            characters: updatedCharacters,
            currentPage: 1,
            hasMore: true,
            isLoading: false,
          ),
        );
        return;
      }

      log('🌐 Загрузка из сети...');
      final apiResponse = await Rest.getCharacters(1);
      final updatedCharacters = await _updateFavoritesStatus(
        apiResponse.results,
      );

      await CacheService.savePage(page: 1, characters: apiResponse.results);

      emit(
        state.copyWith(
          characters: updatedCharacters,
          currentPage: 1,
          hasMore: apiResponse.info.next != null,
          isLoading: false,
        ),
      );
    } catch (e) {
      log('❌ Ошибка загрузки первой страницы: $e');
      emit(state.copyWith(isLoading: false, hasMore: false));
    }
  }

  Future<void> _onLoadMoreCharacters(
    CharacterLoadMoreEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.isLoading || !state.hasMore) return;
    emit(state.copyWith(isLoading: true));

    final nextPage = state.currentPage + 1;

    try {
      if (await CacheService.hasPage(nextPage)) {
        final cachedCharacters = await CacheService.getPage(nextPage);
        final updatedCharacters = await _updateFavoritesStatus(
          cachedCharacters,
        );

        final allCharacters = [...state.characters, ...updatedCharacters];

        emit(
          state.copyWith(
            characters: allCharacters,
            currentPage: nextPage,
            hasMore: true,
            isLoading: false,
          ),
        );
        return;
      }

      log('🌐 Загрузка страницы $nextPage из сети...');
      final apiResponse = await Rest.getCharacters(nextPage);
      final updatedCharacters = await _updateFavoritesStatus(
        apiResponse.results,
      );

      await CacheService.savePage(
        page: nextPage,
        characters: apiResponse.results,
      );

      final allCharacters = [...state.characters, ...updatedCharacters];

      emit(
        state.copyWith(
          characters: allCharacters,
          currentPage: nextPage,
          hasMore: apiResponse.info.next != null,
          isLoading: false,
        ),
      );
    } catch (e) {
      log('❌ Ошибка загрузки страницы $nextPage: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onClickFavorite(
    CharacterClickFavorite event,
    Emitter<CharacterState> emit,
  ) async {
    final characterIndex = state.characters.indexWhere(
      (c) => c.id == event.idCharacter,
    );

    if (characterIndex != -1) {
      final character = state.characters[characterIndex];
      final isCurrentlyFavorite = character.isFavorite;

      final updatedCharacter = character.copyWith(
        isFavorite: !isCurrentlyFavorite,
      );
      final updatedCharacters = List<Character>.from(state.characters);
      updatedCharacters[characterIndex] = updatedCharacter;

      // Обновляем в избранных если персонаж там есть
      final favoriteIndex = state.favoriteCharacters.indexWhere(
        (c) => c.id == event.idCharacter,
      );

      List<Character> updatedFavorites = List.from(state.favoriteCharacters);

      if (!isCurrentlyFavorite) {
        // Добавляем в избранные
        await CacheService.saveFavoriteCharacter(updatedCharacter);
        if (favoriteIndex == -1) {
          updatedFavorites.add(updatedCharacter);
        }
      } else {
        // Удаляем из избранных
        await CacheService.removeFavoriteCharacter(event.idCharacter);
        if (favoriteIndex != -1) {
          updatedFavorites.removeAt(favoriteIndex);
        }
      }

      emit(
        state.copyWith(
          characters: updatedCharacters,
          favoriteCharacters: updatedFavorites,
        ),
      );

      log('⭐ Избранное обновлено: ID ${event.idCharacter}');
    }
  }

  // ========== ЭКРАН ИЗБРАННЫХ ==========

  Future<void> _onLoadFavorites(
    FavoritesLoadEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.isFavoritesLoading) return;

    emit(state.copyWith(isFavoritesLoading: true));

    try {
      final favorites = await CacheService.getAllFavoriteCharacters();

      emit(
        state.copyWith(
          favoriteCharacters: favorites,
          isFavoritesLoading: false,
        ),
      );

      log('✅ Избранные загружены: ${favorites.length} персонажей');
    } catch (e) {
      emit(state.copyWith(isFavoritesLoading: false));
      log('❌ Ошибка загрузки избранных: $e');
    }
  }

  Future<void> _onRemoveFavorite(
    FavoriteRemoveEvent event,
    Emitter<CharacterState> emit,
  ) async {
    // Удаляем из кеша
    await CacheService.removeFavoriteCharacter(event.characterId);

    // Удаляем из списка избранных
    final updatedFavorites = state.favoriteCharacters
        .where((character) => character.id != event.characterId)
        .toList();

    // Обновляем статус в основном списке если персонаж там есть
    final characterIndex = state.characters.indexWhere(
      (c) => c.id == event.characterId,
    );

    List<Character> updatedCharacters = List.from(state.characters);

    if (characterIndex != -1) {
      final character = state.characters[characterIndex];
      updatedCharacters[characterIndex] = character.copyWith(isFavorite: false);
    }

    emit(
      state.copyWith(
        favoriteCharacters: updatedFavorites,
        characters: updatedCharacters,
      ),
    );

    log('🗑️ Персонаж ${event.characterId} удален из избранных');
  }

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

  Future<List<Character>> _updateFavoritesStatus(
    List<Character> characters,
  ) async {
    final List<Character> updated = [];

    for (final character in characters) {
      final isFavorite = await CacheService.isFavorite(character.id);
      updated.add(character.copyWith(isFavorite: isFavorite));
    }

    return updated;
  }
}
