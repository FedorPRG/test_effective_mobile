import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/bloc.dart';
import 'package:test_effective_mobile/bloc/event.dart';
import 'package:test_effective_mobile/bloc/state.dart';
import 'package:test_effective_mobile/views/character_card.dart';

class AllCharacters extends StatefulWidget {
  const AllCharacters({super.key});

  @override
  _AllCharactersState createState() => _AllCharactersState();
}

class _AllCharactersState extends State<AllCharacters> {
  final ScrollController _scrollController = ScrollController();
  static const String _pageStorageKey = 'all_characters_scroll';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = context.read<CharacterBloc>().state as CharacterChange;
      if (!state.isLoading && state.hasMore) {
        context.read<CharacterBloc>().add(const CharacterLoadMoreEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (context, state) {
        final characterState = state as CharacterChange;

        // Если идет первая загрузка и список пустой
        if (characterState.isLoading && characterState.characters.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Основной список
        return ListView.builder(
          key: const PageStorageKey(_pageStorageKey),
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount:
              characterState.characters.length +
              (characterState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == characterState.characters.length) {
              if (characterState.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox();
            }
            return CharacterCard(
              character: characterState.characters[index],
              clickFavorite: () {
                context.read<CharacterBloc>().add(
                  CharacterClickFavorite(
                    idCharacter: characterState.characters[index].id,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
