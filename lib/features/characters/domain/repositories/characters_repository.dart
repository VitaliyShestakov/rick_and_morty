import 'package:rick_and_morty/core/network/request_cancellation.dart';
import 'package:rick_and_morty/features/characters/domain/models/characters_page.dart';

abstract interface class CharactersRepository {
  Future<CharactersPage> fetchPage({
    required int page,
    required String name,
    RequestCancellation? cancellation,
  });
}
