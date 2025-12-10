import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_event.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_state.dart';
import 'package:test_effective_mobile/data/repositories/character_repository.dart';
import 'package:test_effective_mobile/models/character.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRepository _repository;

  CharacterBloc({required CharacterRepository repository})
    : _repository = repository,
      super(
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

  // ========== ЗАГРУЗКА ПЕРВОЙ СТРАНИЦЫ ==========

  Future<void> _onLoadCharacters(
    CharacterLoadEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      final characters = await _repository.getCharacters(1);
      final charactersWithFavorites = await _repository.updateFavoritesStatus(
        characters,
      );
      final hasMore = await _repository.hasNextPage(1);

      emit(
        state.copyWith(
          characters: charactersWithFavorites,
          currentPage: 1,
          hasMore: hasMore,
          isLoading: false,
        ),
      );

      log('✅ Загружено ${charactersWithFavorites.length} персонажей');
    } catch (e) {
      log('❌ Ошибка загрузки первой страницы: $e');
      emit(state.copyWith(isLoading: false, hasMore: false));
    }
  }

  // ========== ПАГИНАЦИЯ ==========

  Future<void> _onLoadMoreCharacters(
    CharacterLoadMoreEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.isLoading || !state.hasMore) return;

    emit(state.copyWith(isLoading: true));

    final nextPage = state.currentPage + 1;

    try {
      final newCharacters = await _repository.getCharacters(nextPage);
      final newCharactersWithFavorites = await _repository
          .updateFavoritesStatus(newCharacters);
      final hasMore = await _repository.hasNextPage(nextPage);

      final allCharacters = [
        ...state.characters,
        ...newCharactersWithFavorites,
      ];

      emit(
        state.copyWith(
          characters: allCharacters,
          currentPage: nextPage,
          hasMore: hasMore,
          isLoading: false,
        ),
      );

      log('✅ Загружено ещё ${newCharactersWithFavorites.length} персонажей');
    } catch (e) {
      log('❌ Ошибка загрузки страницы $nextPage: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  // ========== ИЗБРАННОЕ (ДОБАВЛЕНИЕ/УДАЛЕНИЕ) ==========

  Future<void> _onClickFavorite(
    CharacterClickFavorite event,
    Emitter<CharacterState> emit,
  ) async {
    final characterIndex = state.characters.indexWhere(
      (character) => character.id == event.idCharacter,
    );

    if (characterIndex == -1) return;

    final character = state.characters[characterIndex];
    final isCurrentlyFavorite = character.isFavorite;

    final updatedCharacter = character.copyWith(
      isFavorite: !isCurrentlyFavorite,
    );

    // Обновляем через репозиторий
    await _repository.toggleFavorite(updatedCharacter);

    // Обновляем основной список
    final updatedCharacters = List<Character>.from(state.characters);
    updatedCharacters[characterIndex] = updatedCharacter;

    // ПЕРЕЗАГРУЖАЕМ избранные
    final updatedFavorites = await _repository.getFavoriteCharacters();
    emit(
      state.copyWith(
        characters: updatedCharacters,
        favoriteCharacters: updatedFavorites,
      ),
    );

    log(
      '⭐ Избранное обновлено: ID ${event.idCharacter}, статус: ${!isCurrentlyFavorite}',
    );
  }

  // ========== ЗАГРУЗКА ИЗБРАННЫХ ==========

  Future<void> _onLoadFavorites(
    FavoritesLoadEvent event,
    Emitter<CharacterState> emit,
  ) async {
    if (state.isFavoritesLoading) return;

    emit(state.copyWith(isFavoritesLoading: true));

    try {
      final favorites = await _repository.getFavoriteCharacters();

      emit(
        state.copyWith(
          favoriteCharacters: favorites,
          isFavoritesLoading: false,
        ),
      );

      log('✅ Избранные загружены: ${favorites.length} персонажей');
    } catch (e) {
      log('❌ Ошибка загрузки избранных: $e');
      emit(state.copyWith(isFavoritesLoading: false));
    }
  }

  // ========== УДАЛЕНИЕ ИЗ ИЗБРАННЫХ (с экрана избранных) ==========

  Future<void> _onRemoveFavorite(
    FavoriteRemoveEvent event,
    Emitter<CharacterState> emit,
  ) async {
    await _repository.removeFavorite(event.characterId);

    final updatedFavorites = state.favoriteCharacters
        .where((character) => character.id != event.characterId)
        .toList();

    final characterIndex = state.characters.indexWhere(
      (character) => character.id == event.characterId,
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
  }
}
