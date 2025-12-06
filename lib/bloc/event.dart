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
