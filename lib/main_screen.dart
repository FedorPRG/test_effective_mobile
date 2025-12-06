import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_effective_mobile/bloc/bloc.dart';
import 'package:test_effective_mobile/bloc/event.dart';
import 'package:test_effective_mobile/bloc/state.dart';
import 'package:test_effective_mobile/character_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CharacterBloc>().add(const CharacterLoadEvent());
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
    return Scaffold(
      appBar: AppBar(title: const Text('Rick and Morty'), centerTitle: true),
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          final characterState = state as CharacterChange;

          // Если идет первая загрузка и список пустой
          if (characterState.isLoading && characterState.characters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Основной список
          return ListView.builder(
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
              return CharacterCard(character: characterState.characters[index]);
            },
          );
        },
      ),
    );
  }
}
