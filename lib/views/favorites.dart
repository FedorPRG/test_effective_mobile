import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_event.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_state.dart';
import 'package:test_effective_mobile/models/character.dart';
import 'package:test_effective_mobile/views/character_card.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  FavoritesState createState() => FavoritesState();
}

class FavoritesState extends State<Favorites> {
  String _currentSort = 'id';
  bool _ascending = true;
  final ScrollController _scrollController = ScrollController();
  static const String _pageStorageKey = 'favorites_scroll';

  // Для анимации удаления
  final Set<int> _removingItems = {};
  // Добавляем список таймеров для отслеживания
  final Map<int, Timer> _removalTimers = {};

  @override
  void dispose() {
    // Отменяем все активные таймеры
    for (final timer in _removalTimers.values) {
      timer.cancel();
    }
    _removalTimers.clear();
    _scrollController.dispose();
    super.dispose();
  }

  void _animateRemoval(int characterId) {
    setState(() {
      _removingItems.add(characterId);
    });
    // Отменяем предыдущий таймер для этого персонажа, если он существует
    _removalTimers[characterId]?.cancel();

    // Создаем новый таймер с возможностью отмены
    final timer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _removingItems.remove(characterId);
          _removalTimers.remove(characterId); // Очищаем ссылку
        });
      }
    });
    _removalTimers[characterId] = timer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Text(
                'Сортировка:',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _currentSort,
                dropdownColor: theme.cardColor,
                style: TextStyle(color: theme.colorScheme.onSurface),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentSort = newValue;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('По имени')),
                  DropdownMenuItem(value: 'status', child: Text('По статусу')),
                  DropdownMenuItem(value: 'species', child: Text('По виду')),
                  DropdownMenuItem(value: 'gender', child: Text('По полу')),
                  DropdownMenuItem(value: 'id', child: Text('По ID')),
                ],
              ),
              const Spacer(),
              // Анимированная кнопка сортировки
              AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: _ascending ? 0 : 0.5,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _ascending = !_ascending;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_upward,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Список избранных
        Expanded(
          child: BlocBuilder<CharacterBloc, CharacterState>(
            builder: (context, state) {
              final characterState = state as CharacterChange;

              // Фильтрация и сортировка
              List<Character> favoriteCharacters = characterState.characters
                  .where((character) => character.isFavorite)
                  .toList();

              favoriteCharacters.sort((a, b) {
                int result = 0;
                switch (_currentSort) {
                  case 'name':
                    result = a.name.compareTo(b.name);
                    break;
                  case 'status':
                    result = a.status.compareTo(b.status);
                    break;
                  case 'species':
                    result = a.species.compareTo(b.species);
                    break;
                  case 'gender':
                    result = a.gender.compareTo(b.gender);
                    break;
                  case 'id':
                    result = a.id.compareTo(b.id);
                    break;
                  default:
                    result = a.name.compareTo(b.name);
                }
                return _ascending ? result : -result;
              });

              // Обработка пустого списка
              if (favoriteCharacters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 64,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет избранных персонажей',
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Отображение списка
              return ListView.builder(
                key: const PageStorageKey(_pageStorageKey),
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: favoriteCharacters.length,
                itemBuilder: (context, index) {
                  final character = favoriteCharacters[index];
                  final isRemoving = _removingItems.contains(character.id);

                  // анимация исчезновения
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: isRemoving ? 0 : 1,
                    child: CharacterCard(
                      character: character,
                      clickFavorite: () {
                        // Запускаем анимацию
                        _animateRemoval(character.id);

                        // Удаляем через небольшую задержку для анимации
                        Future.delayed(const Duration(milliseconds: 400), () {
                          if (mounted) {
                            context.read<CharacterBloc>().add(
                              CharacterClickFavorite(idCharacter: character.id),
                            );
                          }
                        });
                      },
                      withPulseAnimation: false,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
