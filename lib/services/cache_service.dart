import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_effective_mobile/models/character.dart';

class CacheService {
  // Ключи
  static const String _pagesKey = 'cached_pages';
  static const String _favoriteCharactersKey = 'favorite_characters';

  // ========== ИЗБРАННЫЕ ПЕРСОНАЖИ ==========

  // Сохранить персонажа в избранные
  static Future<void> saveFavoriteCharacter(Character character) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allFavorites = await _getAllFavoriteCharacters(prefs);

      // Сохраняем полного персонажа
      allFavorites[character.id.toString()] = character.toJson();

      await prefs.setString(_favoriteCharactersKey, json.encode(allFavorites));
      log('✅ Персонаж ${character.id} добавлен в избранные');
    } catch (e) {
      log('❌ Ошибка сохранения избранного персонажа: $e');
    }
  }

  // Удалить персонажа из избранных
  static Future<void> removeFavoriteCharacter(int characterId) async {
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

  // Получить ВСЕХ избранных персонажей
  static Future<List<Character>> getAllFavoriteCharacters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allFavorites = await _getAllFavoriteCharacters(prefs);

      final List<Character> favorites = [];

      allFavorites.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          favorites.add(Character.fromJson(value));
        }
      });

      log('✅ Загружено ${favorites.length} избранных персонажей');
      return favorites;
    } catch (e) {
      log('❌ Ошибка загрузки избранных персонажей: $e');
      return [];
    }
  }

  // Проверить, является ли избранным
  static Future<bool> isFavorite(int characterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allFavorites = await _getAllFavoriteCharacters(prefs);
      return allFavorites.containsKey(characterId.toString());
    } catch (e) {
      log('❌ Ошибка проверки избранного: $e');
      return false;
    }
  }

  // Вспомогательный метод
  static Future<Map<String, dynamic>> _getAllFavoriteCharacters(
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
      return {};
    }
  }

  // ========== ВСЕ ПЕРСОНАЖИ ==========

  //сохранить страницу в кеш
  static Future<void> savePage({
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

  // Получить страницу из кеша
  static Future<List<Character>> getPage(int page) async {
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

  // Проверить, есть ли страница в кеше
  static Future<bool> hasPage(int page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPages = await _getAllPages(prefs);
      return allPages.containsKey(page.toString());
    } catch (e) {
      return false;
    }
  }

  // получить все страницы из кеша
  static Future<Map<String, dynamic>> _getAllPages(
    SharedPreferences prefs,
  ) async {
    try {
      final jsonString = prefs.getString(_pagesKey);
      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }
      final decoded = json.decode(jsonString);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (e) {
      return {};
    }
  }
}
