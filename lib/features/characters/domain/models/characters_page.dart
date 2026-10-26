import 'package:rick_and_morty/features/characters/domain/models/character.dart';

final class CharactersPage {
  CharactersPage({
    required List<Character> characters,
    required this.totalCount,
    required this.nextPage,
  }) : characters = List.unmodifiable(characters);

  final List<Character> characters;
  final int totalCount;
  final int? nextPage;
}
