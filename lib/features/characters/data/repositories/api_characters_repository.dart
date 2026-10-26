import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/network/request_cancellation.dart';
import 'package:rick_and_morty/features/characters/data/datasources/characters_api.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';

final class ApiCharactersRepository implements CharactersRepository {
  const ApiCharactersRepository(this._api);

  final CharactersApi _api;

  @override
  Future<CharactersPage> fetchPage({
    required int page,
    required String name,
    RequestCancellation? cancellation,
  }) async {
    final token = CancelToken();
    cancellation?.whenCancelled.then((_) => token.cancel());
    if (cancellation?.isCancelled ?? false) token.cancel();
    try {
      return await _api.fetchPage(page: page, name: name, cancelToken: token);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) throw const RequestCancelled();
      if (error.response?.statusCode == 404) {
        return CharactersPage(characters: [], totalCount: 0, nextPage: null);
      }
      if (error.response?.statusCode == 429) {
        throw const CharactersFailure(
          'Слишком много запросов к серверу. Подождите немного и попробуйте ещё раз.',
        );
      }
      throw CharactersFailure(switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'Сервер не ответил вовремя. Попробуйте ещё раз.',
        DioExceptionType.connectionError =>
          'Не удалось подключиться. Проверьте интернет и попробуйте ещё раз.',
        _ => 'Не удалось загрузить персонажей. Попробуйте ещё раз.',
      });
    } on FormatException {
      throw const CharactersFailure('Сервер вернул некорректные данные.');
    } on TypeError {
      throw const CharactersFailure('Сервер вернул некорректные данные.');
    }
  }
}
