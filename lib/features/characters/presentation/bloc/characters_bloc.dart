import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/network/request_cancellation.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/characters_event.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/characters_state.dart';

final class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc({
    required this.repository,
    this.searchDebounce = const Duration(milliseconds: 350),
  }) : super(const CharactersInitial()) {
    on<CharactersOpened>(_onOpened);
    on<CharactersSearchChanged>(_onSearchChanged);
    on<CharactersSearchSubmitted>(_onSearchSubmitted);
    on<CharactersNextPageRequested>(_onNextPage);
    on<CharactersRetryRequested>(_onRetry);
  }

  final CharactersRepository repository;
  final Duration searchDebounce;
  Timer? _debounce;
  RequestCancellation? _request;
  int _revision = 0;

  Future<void> _onOpened(
    CharactersOpened event,
    Emitter<CharactersState> emit,
  ) async {
    if (state is! CharactersInitial) return;
    await _loadFirstPage(emit, _revision);
  }

  void _onSearchChanged(
    CharactersSearchChanged event,
    Emitter<CharactersState> emit,
  ) {
    final query = event.query.trim();
    if (query == state.query) return;
    _debounce?.cancel();
    _request?.cancel();
    final revision = ++_revision;
    emit(CharactersLoading(query: query));
    _debounce = Timer(
      query.isEmpty ? Duration.zero : searchDebounce,
      () => add(CharactersSearchSubmitted(revision)),
    );
  }

  Future<void> _onSearchSubmitted(
    CharactersSearchSubmitted event,
    Emitter<CharactersState> emit,
  ) async {
    if (event.revision != _revision) return;
    await _loadFirstPage(emit, event.revision);
  }

  Future<void> _onRetry(
    CharactersRetryRequested event,
    Emitter<CharactersState> emit,
  ) async {
    if (state is CharactersError) {
      await _loadFirstPage(emit, _revision);
    } else if (state case CharactersLoaded(:final paginationError)) {
      if (paginationError != null) await _loadNextPage(emit);
    }
  }

  Future<void> _onNextPage(
    CharactersNextPageRequested event,
    Emitter<CharactersState> emit,
  ) async {
    if (state case CharactersLoaded(paginationError: null)) {
      await _loadNextPage(emit);
    }
  }

  Future<void> _loadFirstPage(
    Emitter<CharactersState> emit,
    int revision,
  ) async {
    final query = state.query;
    final token = RequestCancellation();
    _request = token;
    emit(CharactersLoading(query: query));
    try {
      final page = await repository.fetchPage(
        page: 1,
        name: query,
        cancellation: token,
      );
      if (!_isCurrent(emit, revision, token)) return;
      emit(
        page.characters.isEmpty
            ? CharactersEmpty(query: query)
            : CharactersLoaded(
                query: query,
                characters: page.characters,
                totalCount: page.totalCount,
                nextPage: page.nextPage,
              ),
      );
    } catch (error) {
      if (!_isCurrent(emit, revision, token)) return;
      emit(CharactersError(query: query, message: _message(error)));
    }
  }

  Future<void> _loadNextPage(Emitter<CharactersState> emit) async {
    final current = state;
    if (current is! CharactersLoaded ||
        current.isLoadingMore ||
        current.nextPage == null) {
      return;
    }
    final revision = _revision;
    final token = RequestCancellation();
    _request = token;
    emit(current.withPagination(isLoadingMore: true));
    try {
      final page = await repository.fetchPage(
        page: current.nextPage!,
        name: current.query,
        cancellation: token,
      );
      if (!_isCurrent(emit, revision, token)) return;
      final byId = {
        for (final character in current.characters) character.id: character,
      };
      for (final character in page.characters) {
        byId[character.id] = character;
      }
      emit(
        CharactersLoaded(
          query: current.query,
          characters: byId.values.toList(),
          totalCount: page.totalCount,
          nextPage: page.nextPage,
        ),
      );
    } catch (error) {
      if (!_isCurrent(emit, revision, token)) return;
      emit(current.withPagination(error: _message(error)));
    }
  }

  bool _isCurrent(
    Emitter<CharactersState> emit,
    int revision,
    RequestCancellation token,
  ) => !emit.isDone && revision == _revision && !token.isCancelled;

  String _message(Object error) => error is CharactersFailure
      ? error.message
      : 'Не удалось загрузить персонажей. Попробуйте ещё раз.';

  @override
  Future<void> close() {
    _debounce?.cancel();
    _request?.cancel();
    return super.close();
  }
}
