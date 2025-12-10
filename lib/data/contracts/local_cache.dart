import 'package:test_effective_mobile/models/character.dart';

abstract class LocalCache {
  // Для всех персонажей
  Future<bool> hasPage(int page);
  Future<List<Character>> getPage(int page);
  Future<void> savePage({
    required int page,
    required List<Character> characters,
  });
  Future<int> getPageCount(int page);
  // Для избранных
  Future<void> saveFavoriteCharacter(Character character);
  Future<void> removeFavoriteCharacter(int characterId);
  Future<List<Character>> getAllFavoriteCharacters();
  Future<bool> isFavorite(int characterId);
}
