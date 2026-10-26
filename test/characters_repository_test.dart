import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/core/network/api_client.dart';
import 'package:rick_and_morty/core/network/request_cancellation.dart';
import 'package:rick_and_morty/features/characters/data/data.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter({this.status = 200, this.body, this.failure});

  final int status;
  final Object? body;
  final DioExceptionType? failure;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _PendingAdapter implements HttpClientAdapter {
  final started = Completer<void>();
  final aborted = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    started.complete();
    await cancelFuture!;
    aborted.complete();
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;

  setUp(() => dio = ApiClient.create());
  tearDown(() => dio.close(force: true));

  test(
    'domain cancellation aborts the HTTP request without exposing Dio errors',
    () async {
      final adapter = _PendingAdapter();
      dio.httpClientAdapter = adapter;
      final cancellation = RequestCancellation();
      final request = ApiCharactersRepository(CharactersApi(dio))
          .fetchPage(page: 1, name: 'Rick', cancellation: cancellation);
      final assertion = expectLater(request, throwsA(isA<RequestCancelled>()));
      await adapter.started.future;
      cancellation.cancel();
      await assertion;
      await adapter.aborted.future;
    },
  );

  ApiCharactersRepository repository(_Adapter adapter) {
    dio.httpClientAdapter = adapter;
    return ApiCharactersRepository(CharactersApi(dio));
  }

  test('maps character fields, pagination and search parameters', () async {
    final adapter = _Adapter(
      body: {
        'info': {
          'count': 21,
          'next': 'https://rickandmortyapi.com/api/character?page=2&name=Rick',
        },
        'results': [
          {
            'id': 1,
            'name': 'Rick Sanchez',
            'image': 'https://example.com/rick.png',
            'status': 'Alive',
            'species': 'Human',
            'origin': {'name': 'Earth (C-137)'},
            'location': {'name': 'Citadel of Ricks'},
          },
        ],
      },
    );
    final result = await repository(adapter)
        .fetchPage(page: 1, name: 'Rick & Morty');
    expect(adapter.request!.queryParameters, {
      'page': 1,
      'name': 'Rick & Morty',
    });
    expect(result.nextPage, 2);
    expect(result.totalCount, 21);
    expect(
      result.characters.single,
      const Character(
        id: 1,
        name: 'Rick Sanchez',
        image: 'https://example.com/rick.png',
        status: CharacterStatus.alive,
        species: 'Human',
        origin: 'Earth (C-137)',
        location: 'Citadel of Ricks',
      ),
    );
  });

  test('404 means empty results rather than a loading error', () async {
    final result = await repository(
      _Adapter(status: 404, body: {'error': 'There is nothing here'}),
    ).fetchPage(page: 1, name: 'nobody');
    expect(result.characters, isEmpty);
    expect(result.nextPage, isNull);
    expect(result.totalCount, 0);
  });

  test(
    'network errors, timeouts and server errors become readable failures',
    () async {
      for (final adapter in [
        _Adapter(failure: DioExceptionType.connectionError),
        _Adapter(failure: DioExceptionType.receiveTimeout),
        _Adapter(status: 503),
        _Adapter(status: 429),
        _Adapter(body: {'unexpected': true}),
      ]) {
        await expectLater(
          repository(adapter).fetchPage(page: 1, name: ''),
          throwsA(
            isA<CharactersFailure>().having(
              (error) => error.message,
              'message',
              isNotEmpty,
            ),
          ),
        );
      }
    },
  );
}
