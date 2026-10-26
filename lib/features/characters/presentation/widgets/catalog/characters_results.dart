import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/catalog/characters_list.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharactersResults extends StatelessWidget {
  const CharactersResults({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CharactersBloc, CharactersState>(
        builder: (context, state) => switch (state) {
          CharactersInitial() ||
          CharactersLoading() => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: AppLoadingIndicator(size: 36, label: 'Ищем во вселенной…'),
            ),
          ),
          CharactersEmpty() => SliverFillRemaining(
            hasScrollBody: false,
            child: AppMessage(
              icon: Icons.travel_explore_rounded,
              title: 'Никого не нашли',
              message: state.query.isEmpty
                  ? 'В этой вселенной пока пусто.'
                  : 'Попробуйте другое имя.\nНапример, Rick или Morty.',
              action: state.query.isEmpty
                  ? null
                  : FilledButton(
                      onPressed: onClear,
                      child: const Text('Сбросить поиск'),
                    ),
            ),
          ),
          CharactersError(:final message) => SliverFillRemaining(
            hasScrollBody: false,
            child: AppMessage(
              icon: Icons.wifi_off_rounded,
              title: 'Связь с миром потеряна',
              message: message,
              action: FilledButton(
                onPressed: () => context.read<CharactersBloc>().add(
                  const CharactersRetryRequested(),
                ),
                child: const Text('Попробовать снова'),
              ),
            ),
          ),
          CharactersLoaded() => CharactersList(state: state),
        },
      );
}
