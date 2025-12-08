import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_bloc.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_event.dart';
import 'package:test_effective_mobile/bloc/character_bloc/character_state.dart';
import 'package:test_effective_mobile/views/character_card.dart';

class AllCharacters extends StatefulWidget {
  const AllCharacters({super.key});

  @override
  AllCharactersState createState() => AllCharactersState();
}

class AllCharactersState extends State<AllCharacters> {
  final ScrollController _scrollController = ScrollController();
  static const String _pageStorageKey = 'all_characters_scroll';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
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
              withPulseAnimation: true,
            );
          },
        );
      },
    );
  }
}
