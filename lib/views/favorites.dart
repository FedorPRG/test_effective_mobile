import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/bloc.dart';
import 'package:test_effective_mobile/bloc/event.dart';
import 'package:test_effective_mobile/bloc/state.dart';
import 'package:test_effective_mobile/models/character.dart';
import 'package:test_effective_mobile/views/character_card.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  String _currentSort = 'id';
  bool _ascending = true;
  final ScrollController _scrollController = ScrollController();
  static const String _pageStorageKey = 'favorites_scroll';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              const Text('Сортировка:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _currentSort,
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
              IconButton(
                onPressed: () {
                  setState(() {
                    _ascending = !_ascending;
                  });
                },
                icon: Icon(
                  _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.blue,
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
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Нет избранных персонажей',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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
                  return CharacterCard(
                    character: favoriteCharacters[index],
                    clickFavorite: () {
                      context.read<CharacterBloc>().add(
                        CharacterClickFavorite(
                          idCharacter: favoriteCharacters[index].id,
                        ),
                      );
                    },
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
