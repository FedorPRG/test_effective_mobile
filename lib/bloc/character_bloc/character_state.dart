import 'package:equatable/equatable.dart';
import 'package:test_effective_mobile/models/character.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object> get props => [];
}

class CharacterChange extends CharacterState {
  final List<Character> characters;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;

  const CharacterChange({
    required this.characters,
    required this.currentPage,
    required this.hasMore,
    required this.isLoading,
  });

  CharacterChange copyWith({
    List<Character>? characters,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
  }) {
    return CharacterChange(
      characters: characters ?? this.characters,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [characters, currentPage, hasMore, isLoading];
}
