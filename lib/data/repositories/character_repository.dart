import 'dart:developer';

import 'package:test_effective_mobile/data/contracts/api_client.dart';
import 'package:test_effective_mobile/data/contracts/local_cache.dart';
import 'package:test_effective_mobile/models/character.dart';

class CharacterRepository {
  final ApiClient _apiClient;
  final LocalCache _localCache;

  CharacterRepository({
    required ApiClient apiClient,
    required LocalCache localCache,
  }) : _apiClient = apiClient,
       _localCache = localCache;

  // Метод для получения персонажей с логикой "сначала кэш, потом сеть"
  Future<List<Character>> getCharacters(int page) async {
    // 1. Проверяем кэш
    if (await _localCache.hasPage(page)) {
      return await _localCache.getPage(page);
    }

    // 2. Если нет в кэше, идем в сеть
    final apiResponse = await _apiClient.getCharacters(page);

    // 3. Сохраняем в кэш
    await _localCache.savePage(page: page, characters: apiResponse.results);

    return apiResponse.results;
  }

  // Метод для проверки наличия следующей страницы
  Future<bool> hasNextPage(int currentPage) async {
    try {
      // Быстрая проверка: если есть страница в кеше
      if (await _localCache.hasPage(currentPage)) {
        final cachedCount = await _localCache.getPageCount(currentPage);
        return cachedCount ==
            20; // Стандартный размер страницы Rick and Morty API
      }

      // Если нет в кеше - проверяем сеть
      final apiResponse = await _apiClient.getCharacters(currentPage);
      return apiResponse.info.next != null;
    } catch (e) {
      log('⚠️ Ошибка проверки следующей страницы: $e');
      return false;
    }
  }

  // Избранное
  Future<List<Character>> getFavoriteCharacters() async {
    return await _localCache.getAllFavoriteCharacters();
  }

  Future<void> toggleFavorite(Character character) async {
    if (character.isFavorite) {
      await _localCache.saveFavoriteCharacter(character);
    } else {
      await _localCache.removeFavoriteCharacter(character.id);
    }
  }

  Future<void> removeFavorite(int characterId) async {
    await _localCache.removeFavoriteCharacter(characterId);
  }

  Future<List<Character>> updateFavoritesStatus(
    List<Character> characters,
  ) async {
    final updated = <Character>[];
    for (final character in characters) {
      final isFavorite = await _localCache.isFavorite(character.id);
      updated.add(character.copyWith(isFavorite: isFavorite));
    }
    return updated;
  }
}
