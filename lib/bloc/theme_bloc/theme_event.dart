import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeToggleEvent extends ThemeEvent {
  const ThemeToggleEvent();
}

class ThemeLoadEvent extends ThemeEvent {
  const ThemeLoadEvent();
}
