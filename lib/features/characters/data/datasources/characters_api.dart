import 'package:dio/dio.dart';
import 'package:rick_and_morty/features/characters/data/mappers/characters_mapper.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';

final class CharactersApi {
  CharactersApi(this._dio);

  final Dio _dio;

  Future<CharactersPage> fetchPage({
    required int page,
    required String name,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/character',
      queryParameters: {'page': page, if (name.isNotEmpty) 'name': name},
      cancelToken: cancelToken,
    );
    return CharactersMapper.page(response.data!);
  }
}
