import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_effective_mobile/data/contracts/local_cache.dart';
import 'package:test_effective_mobile/models/character.dart';

class SharedPrefsCache implements LocalCache {
  // Ключи для SharedPreferences
  static const String _pagesKey = 'cached_pages';
  static const String _favoriteCharactersKey = 'favorite_characters';

  @override
  Future<int> getPageCount(int page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPages = await _getAllPages(prefs);

      final pageData = allPages[page.toString()];
      if (pageData == null || pageData is! List) {
        return 0;
      }

      return pageData.length;
    } catch (e) {
      log('❌ Ошибка получения количества страницы $page: $e');
      return 0;
    }
  }

  @override
  Future<bool> hasPage(int page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPages = await _getAllPages(prefs);
      return allPages.containsKey(page.toString());
    } catch (e) {
      log('❌ Ошибка проверки наличия страницы $page: $e');
      return false;
    }
  }

  @override
  Future<List<Character>> getPage(int page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPages = await _getAllPages(prefs);

      final pageData = allPages[page.toString()];
      if (pageData == null || pageData is! List) {
        return [];
      }

      final List<Character> characters = [];
      for (final item in pageData) {
        if (item is Map<String, dynamic>) {
          characters.add(Character.fromJson(item));
        }
      }

      log('✅ Страница $page загружена из кеша');
      return characters;
    } catch (e) {
      log('❌ Ошибка загрузки страницы $page: $e');
      return [];
    }
  }

  @override
  Future<void> savePage({
    required int page,
    required List<Character> characters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPages = await _getAllPages(prefs);

      allPages[page.toString()] = characters.map((c) => c.toJson()).toList();

      await prefs.setString(_pagesKey, json.encode(allPages));
      log('✅ Страница $page сохранена в кеш');
    } catch (e) {
      log('❌ Ошибка сохранения страницы $page: $e');
    }
  }

  @override
  Future<void> saveFavoriteCharacter(Character character) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allFavorites = await _getAllFavoriteCharacters(prefs);

      // Сохраняем полного персонажа
      allFavorites[character.id.toString()] = character.toJson();

      await prefs.setString(_favoriteCharactersKey, json.encode(allFavorites));
    } catch (e) {
      log('$e');
    }
  }

  @override
  Future<void> removeFavoriteCharacter(int characterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allFavorites = await _getAllFavoriteCharacters(prefs);

      allFavorites.remove(characterId.toString());

      await prefs.setString(_favoriteCharactersKey, json.encode(allFavorites));
      log('✅ Персонаж $characterId удален из избранных');
    } catch (e) {
      log('❌ Ошибка удаления избранного персонажа: $e');
    }
  }

  @override
  Future<List<Character>> getAllFavoriteCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allFavorites = await _getAllFavoriteCharacters(prefs);

      final List<Character> favorites = [];

      allFavorites.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final character = Character.fromJson(value);
          favorites.add(character);
        }
      });

      log('✅ Загружено ${favorites.length} избранных персонажей');
      return favorites;
    } catch (e) {
      log('❌ Ошибка загрузки избранных персонажей: $e');
      return [];
    }
  }

  @override
  Future<bool> isFavorite(int characterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allFavorites = await _getAllFavoriteCharacters(prefs);
      return allFavorites.containsKey(characterId.toString());
    } catch (e) {
      log('❌ Ошибка проверки избранного: $e');
      return false;
    }
  }

  /// Получить все сохраненные страницы из SharedPreferences
  Future<Map<String, dynamic>> _getAllPages(SharedPreferences prefs) async {
    try {
      final jsonString = prefs.getString(_pagesKey);
      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }
      final decoded = json.decode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (e) {
      log('❌ Ошибка парсинга кешированных страниц: $e');
      return {};
    }
  }

  /// Получить всех избранных персонажей из SharedPreferences
  Future<Map<String, dynamic>> _getAllFavoriteCharacters(
    SharedPreferences prefs,
  ) async {
    try {
      final jsonString = prefs.getString(_favoriteCharactersKey);
      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }
      final decoded = json.decode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (e) {
      log('❌ Ошибка парсинга избранных персонажей: $e');
      return {};
    }
  }
}
