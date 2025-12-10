import 'package:equatable/equatable.dart';
import 'package:test_effective_mobile/models/character.dart';

class CharacterState extends Equatable {
  final List<Character> characters;
  final List<Character> favoriteCharacters;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isFavoritesLoading;

  const CharacterState({
    required this.characters,
    required this.favoriteCharacters,
    required this.currentPage,
    required this.hasMore,
    required this.isLoading,
    required this.isFavoritesLoading,
  });

  CharacterState copyWith({
    List<Character>? characters,
    List<Character>? favoriteCharacters,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isFavoritesLoading,
  }) {
    return CharacterState(
      characters: characters ?? this.characters,
      favoriteCharacters: favoriteCharacters ?? this.favoriteCharacters,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isFavoritesLoading: isFavoritesLoading ?? this.isFavoritesLoading,
    );
  }

  @override
  List<Object> get props => [
    characters,
    favoriteCharacters,
    currentPage,
    hasMore,
    isLoading,
    isFavoritesLoading,
  ];
}
