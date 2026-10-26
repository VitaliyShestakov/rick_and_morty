import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/catalog/characters_header.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/catalog/characters_results.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  final _search = TextEditingController();
  late final _scroll = PaginatedScrollController(
    onLoadMore: () =>
        context.read<CharactersBloc>().add(const CharactersNextPageRequested()),
  );

  @override
  void initState() {
    super.initState();
    _scheduleMetrics();
  }

  void _scheduleMetrics() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _scroll.refreshMetrics();
  });

  void _onStateChanged(BuildContext context, CharactersState state) {
    if (state is CharactersLoading) _scroll.reset();
    if (state is CharactersLoaded) _scheduleMetrics();
  }

  void _clearSearch() {
    _search.clear();
    context.read<CharactersBloc>().add(const CharactersSearchChanged(''));
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    floatingActionButton: ScrollToTopButton(controller: _scroll),
    body: BlocListener<CharactersBloc, CharactersState>(
      listener: _onStateChanged,
      child: CustomScrollView(
        key: const PageStorageKey('characters-list'),
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          CharactersHeader(searchController: _search, onClear: _clearSearch),
          CharactersResults(onClear: _clearSearch),
        ],
      ),
    ),
  );
}
