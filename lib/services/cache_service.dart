import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_effective_mobile/models/character.dart';

class CacheService {
  static const String _pagesKey = 'cached_pages';

  // Сохранить одну страницу в кеш
  static Future<void> savePage({
    required int page,
    required List<Character> characters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPages = await _getAllPages(prefs);

      // Сохраняем персонажей с их текущим состоянием isFavorite
      allPages[page.toString()] = characters.map((c) => c.toJson()).toList();

      await prefs.setString(_pagesKey, json.encode(allPages));
      log('✅ Страница $page сохранена в кеш (${characters.length} персонажей)');
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

      log(
        '✅ Страница $page загружена из кеша (${characters.length} персонажей)',
      );
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

  // Обновить состояние избранного для одного персонажа во всех страницах
  static Future<void> updateFavoriteStatus(
    int characterId,
    bool isFavorite,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPages = await _getAllPages(prefs);
      bool updated = false;

      for (final pageKey in allPages.keys) {
        final pageData = allPages[pageKey] as List;
        final updatedPageData = <Map<String, dynamic>>[];

        for (final item in pageData) {
          final Map<String, dynamic> charData = Map<String, dynamic>.from(item);
          if (charData['id'] == characterId) {
            charData['isFavorite'] = isFavorite;
            updated = true;
          }
          updatedPageData.add(charData);
        }

        allPages[pageKey] = updatedPageData;
      }

      if (updated) {
        await prefs.setString(_pagesKey, json.encode(allPages));
        log('✅ Избранное обновлено для персонажа ID: $characterId');
      }
    } catch (e) {
      log('❌ Ошибка обновления избранного: $e');
    }
  }

  // получить все страницы
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
