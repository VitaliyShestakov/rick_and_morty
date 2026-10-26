import 'package:equatable/equatable.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';

sealed class CharactersState extends Equatable {
  const CharactersState({this.query = ''});

  final String query;

  @override
  List<Object?> get props => [query];
}

final class CharactersInitial extends CharactersState {
  const CharactersInitial();
}

final class CharactersLoading extends CharactersState {
  const CharactersLoading({required super.query});
}

final class CharactersLoaded extends CharactersState {
  CharactersLoaded({
    required super.query,
    required List<Character> characters,
    required this.totalCount,
    required this.nextPage,
    this.isLoadingMore = false,
    this.paginationError,
  }) : characters = List.unmodifiable(characters);

  final List<Character> characters;
  final int totalCount;
  final int? nextPage;
  final bool isLoadingMore;
  final String? paginationError;

  CharactersLoaded withPagination({
    bool isLoadingMore = false,
    String? error,
  }) => CharactersLoaded(
    query: query,
    characters: characters,
    totalCount: totalCount,
    nextPage: nextPage,
    isLoadingMore: isLoadingMore,
    paginationError: error,
  );

  @override
  List<Object?> get props => [
    ...super.props,
    characters,
    totalCount,
    nextPage,
    isLoadingMore,
    paginationError,
  ];
}

final class CharactersEmpty extends CharactersState {
  const CharactersEmpty({required super.query});
}

final class CharactersError extends CharactersState {
  const CharactersError({required super.query, required this.message});

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
