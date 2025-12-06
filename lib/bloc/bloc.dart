import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/event.dart';
import 'package:test_effective_mobile/bloc/state.dart';
import 'package:test_effective_mobile/rest.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc()
    : super(
        CharacterChange(
          characters: [],
          currentPage: 1,
          hasMore: true,
          isLoading: false,
        ),
      ) {
    on<CharacterLoadEvent>(_onLoadCharacters);
    on<CharacterLoadMoreEvent>(_onLoadMoreCharacters);
  }

  Future<void> _onLoadCharacters(
    CharacterLoadEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final currentState = state as CharacterChange;

    // Если уже загружается, игнорируем
    if (currentState.isLoading) {
      return;
    }

    emit(currentState.copyWith(isLoading: true));

    try {
      final apiResponse = await Rest.getCharacters(currentState.currentPage);

      emit(
        CharacterChange(
          characters: apiResponse.results,
          currentPage: currentState.currentPage,
          hasMore: apiResponse.info.next != null,
          isLoading: false,
        ),
      );
    } catch (e) {
      log('Ошибка загрузки персонажей: $e');
      emit(currentState.copyWith(isLoading: false));
    }
  }

  Future<void> _onLoadMoreCharacters(
    CharacterLoadMoreEvent event,
    Emitter<CharacterState> emit,
  ) async {
    final currentState = state as CharacterChange;

    // Если уже загружается или нет больше данных, игнорируем
    if (currentState.isLoading || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoading: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final apiResponse = await Rest.getCharacters(nextPage);

      if (apiResponse.results.isNotEmpty) {
        final newCharacters = [
          ...currentState.characters,
          ...apiResponse.results,
        ];

        emit(
          CharacterChange(
            characters: newCharacters,
            currentPage: nextPage,
            hasMore: apiResponse.info.next != null,
            isLoading: false,
          ),
        );
      } else {
        emit(currentState.copyWith(hasMore: false, isLoading: false));
      }
    } catch (e) {
      log('Ошибка загрузки персонажей: $e');
      emit(currentState.copyWith(hasMore: false, isLoading: false));
    }
  }
}
