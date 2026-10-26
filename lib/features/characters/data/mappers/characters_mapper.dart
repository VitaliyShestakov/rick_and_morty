import 'package:rick_and_morty/features/characters/domain/domain.dart';

abstract final class CharactersMapper {
  static CharactersPage page(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>;
    final next = info['next'] as String?;
    return CharactersPage(
      characters: (json['results'] as List<dynamic>)
          .map((item) => character(item as Map<String, dynamic>))
          .toList(),
      totalCount: info['count'] as int,
      nextPage: next == null
          ? null
          : int.parse(Uri.parse(next).queryParameters['page']!),
    );
  }

  static Character character(Map<String, dynamic> json) => Character(
    id: json['id'] as int,
    name: json['name'] as String,
    image: json['image'] as String,
    status: switch (json['status']) {
      'Alive' => CharacterStatus.alive,
      'Dead' => CharacterStatus.dead,
      _ => CharacterStatus.unknown,
    },
    species: json['species'] as String,
    origin: (json['origin'] as Map<String, dynamic>)['name'] as String,
    location: (json['location'] as Map<String, dynamic>)['name'] as String,
  );
}
