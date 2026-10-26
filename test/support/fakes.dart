import 'dart:async';

import 'package:rick_and_morty/core/network/request_cancellation.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';

Character character(int id, {String? name}) => Character(
  id: id,
  name: name ?? 'Character $id',
  image: 'https://example.com/$id.png',
  status: CharacterStatus.alive,
  species: 'Human',
  origin: 'Earth (C-137)',
  location: 'Citadel of Ricks',
);

CharactersPage page(List<int> ids, {int? nextPage, int totalCount = 40}) =>
    CharactersPage(
      characters: ids.map((id) => character(id)).toList(),
      totalCount: totalCount,
      nextPage: nextPage,
    );

class PendingRequest {
  PendingRequest(this.pageNumber, this.name, this.token);

  final int pageNumber;
  final String name;
  final RequestCancellation? token;
  final completer = Completer<CharactersPage>();
}

class ControlledRepository implements CharactersRepository {
  final requests = <PendingRequest>[];

  @override
  Future<CharactersPage> fetchPage({
    required int page,
    required String name,
    RequestCancellation? cancellation,
  }) {
    final request = PendingRequest(page, name, cancellation);
    requests.add(request);
    return request.completer.future;
  }
}

class MemoryRepository implements CharactersRepository {
  final requests = <({int page, String name})>[];

  @override
  Future<CharactersPage> fetchPage({
    required int page,
    required String name,
    RequestCancellation? cancellation,
  }) async {
    requests.add((page: page, name: name));
    return CharactersPage(
      characters: List.generate(
        20,
        (index) => character(index + 1, name: '$name ${index + 1}'),
      ),
      totalCount: 20,
      nextPage: null,
    );
  }
}
