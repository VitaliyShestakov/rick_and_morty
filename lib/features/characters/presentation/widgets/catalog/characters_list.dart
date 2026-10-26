import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/screens/character_details_screen.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character/character_card.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharactersList extends StatelessWidget {
  const CharactersList({super.key, required this.state});

  final CharactersLoaded state;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppLayout.gutter,
      0,
      AppLayout.gutter,
      AppSpacing.lg,
    ),
    sliver: SliverList.separated(
      itemCount: state.characters.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == state.characters.length) {
          return AppPaginationFooter(
            isLoading: state.isLoadingMore,
            hasNextPage: state.nextPage != null,
            error: state.paginationError,
            endLabel: 'Вы исследовали всех персонажей',
            onRetry: () => context.read<CharactersBloc>().add(
              const CharactersRetryRequested(),
            ),
          );
        }
        final character = state.characters[index];
        return CharacterCard(
          key: ValueKey('character-${character.id}'),
          character: character,
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).push(CharacterDetailsScreen.route(character));
          },
        );
      },
    ),
  );
}
