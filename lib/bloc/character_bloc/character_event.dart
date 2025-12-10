import 'package:equatable/equatable.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class CharacterLoadEvent extends CharacterEvent {
  const CharacterLoadEvent();
}

class CharacterLoadMoreEvent extends CharacterEvent {
  const CharacterLoadMoreEvent();
}

class CharacterClickFavorite extends CharacterEvent {
  final int idCharacter;
  const CharacterClickFavorite({required this.idCharacter});

  @override
  List<Object> get props => [idCharacter];
}

class FavoritesLoadEvent extends CharacterEvent {
  const FavoritesLoadEvent();
}

class FavoriteRemoveEvent extends CharacterEvent {
  final int characterId;
  const FavoriteRemoveEvent({required this.characterId});

  @override
  List<Object> get props => [characterId];
}
