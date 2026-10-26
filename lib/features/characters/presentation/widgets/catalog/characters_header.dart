import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharactersHeader extends StatelessWidget {
  const CharactersHeader({
    super.key,
    required this.searchController,
    required this.onClear,
  });

  final TextEditingController searchController;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppLayout.gutter,
      AppSpacing.lg,
      AppLayout.gutter,
      AppSpacing.md,
    ),
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBrandHeader(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Вселенная\nв лицах',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Знакомые герои. Бесконечные миры.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSearchField(
            key: const ValueKey('character-search'),
            controller: searchController,
            hintText: 'Найти персонажа по имени',
            onClear: onClear,
            onChanged: (query) => context.read<CharactersBloc>().add(
              CharactersSearchChanged(query),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _ResultsHeading(),
        ],
      ),
    ),
  );
}

class _ResultsHeading extends StatelessWidget {
  const _ResultsHeading();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        CharactersBloc,
        CharactersState,
        ({String query, int? count})
      >(
        selector: (state) => (
          query: state.query,
          count: state is CharactersLoaded ? state.totalCount : null,
        ),
        builder: (_, heading) => AppSectionHeader(
          title: heading.query.isEmpty ? 'ПЕРСОНАЖИ' : 'РЕЗУЛЬТАТЫ ПОИСКА',
          trailing: heading.count == null
              ? null
              : AppBadge(
                  label: '${heading.count}',
                  color: AppColors.accent,
                  backgroundColor: AppColors.elevated,
                ),
        ),
      );
}
