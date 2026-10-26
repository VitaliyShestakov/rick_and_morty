import 'package:equatable/equatable.dart';

sealed class CharactersEvent extends Equatable {
  const CharactersEvent();

  @override
  List<Object> get props => [];
}

final class CharactersOpened extends CharactersEvent {
  const CharactersOpened();
}

final class CharactersSearchChanged extends CharactersEvent {
  const CharactersSearchChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

final class CharactersNextPageRequested extends CharactersEvent {
  const CharactersNextPageRequested();
}

final class CharactersRetryRequested extends CharactersEvent {
  const CharactersRetryRequested();
}

final class CharactersSearchSubmitted extends CharactersEvent {
  const CharactersSearchSubmitted(this.revision);

  final int revision;

  @override
  List<Object> get props => [revision];
}
