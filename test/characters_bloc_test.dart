import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';

import 'support/fakes.dart';

void main() {
  test('loads pages once, deduplicates characters, stops at the last page', () {
    fakeAsync((async) {
      final repository = ControlledRepository();
      final bloc = CharactersBloc(repository: repository);
      final states = <CharactersState>[];
      bloc.stream.listen(states.add);
      bloc.add(const CharactersOpened());
      async.flushMicrotasks();
      expect(bloc.state, isA<CharactersLoading>());
      repository.requests[0].completer.complete(page([1, 2], nextPage: 2));
      async.flushMicrotasks();
      bloc.add(const CharactersNextPageRequested());
      bloc.add(const CharactersNextPageRequested());
      async.flushMicrotasks();
      expect(repository.requests.length, 2);
      expect(repository.requests[1].pageNumber, 2);
      expect((bloc.state as CharactersLoaded).isLoadingMore, isTrue);
      repository.requests[1].completer.complete(page([2, 3]));
      async.flushMicrotasks();
      final loaded = bloc.state as CharactersLoaded;
      expect(loaded.characters.map((character) => character.id), [1, 2, 3]);
      expect(loaded.nextPage, isNull);
      bloc.add(const CharactersNextPageRequested());
      async.flushMicrotasks();
      expect(repository.requests.length, 2);
      expect(states.map((state) => state.runtimeType), [
        CharactersLoading,
        CharactersLoaded,
        CharactersLoaded,
        CharactersLoaded,
      ]);
      bloc.close();
      async.flushMicrotasks();
    });
  });

  test('retries first page and pagination failures without losing cards', () {
    fakeAsync((async) {
      final repository = ControlledRepository();
      final bloc = CharactersBloc(repository: repository);
      bloc.add(const CharactersOpened());
      async.flushMicrotasks();
      repository.requests[0].completer.completeError(
        const CharactersFailure('Нет сети'),
      );
      async.flushMicrotasks();
      expect(bloc.state, const CharactersError(query: '', message: 'Нет сети'));
      bloc.add(const CharactersRetryRequested());
      async.flushMicrotasks();
      repository.requests[1].completer.complete(page([1], nextPage: 2));
      async.flushMicrotasks();
      bloc.add(const CharactersNextPageRequested());
      async.flushMicrotasks();
      repository.requests[2].completer.completeError(
        const CharactersFailure('Нет сети'),
      );
      async.flushMicrotasks();
      expect((bloc.state as CharactersLoaded).characters.single.id, 1);
      expect((bloc.state as CharactersLoaded).paginationError, 'Нет сети');
      bloc.add(const CharactersNextPageRequested());
      async.flushMicrotasks();
      expect(repository.requests.length, 3);
      bloc.add(const CharactersRetryRequested());
      bloc.add(const CharactersRetryRequested());
      async.flushMicrotasks();
      expect(repository.requests.length, 4);
      expect(repository.requests.last.pageNumber, 2);
      repository.requests.last.completer.complete(page([2]));
      async.flushMicrotasks();
      expect(
        (bloc.state as CharactersLoaded).characters.map(
          (character) => character.id,
        ),
        [1, 2],
      );
      expect((bloc.state as CharactersLoaded).paginationError, isNull);
      bloc.close();
      async.flushMicrotasks();
    });
  });

  test(
    'debounces search, cancels old requests and rejects stale responses',
    () {
      fakeAsync((async) {
        final repository = ControlledRepository();
        final bloc = CharactersBloc(repository: repository);
        bloc.add(const CharactersOpened());
        async.flushMicrotasks();
        repository.requests[0].completer.complete(page([1], nextPage: 2));
        async.flushMicrotasks();
        bloc.add(const CharactersNextPageRequested());
        async.flushMicrotasks();
        bloc.add(const CharactersSearchChanged('R'));
        async.flushMicrotasks();
        expect(repository.requests[1].token!.isCancelled, isTrue);
        async.elapse(const Duration(milliseconds: 200));
        bloc.add(const CharactersSearchChanged(' Rick '));
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 349));
        expect(repository.requests.length, 2);
        async.elapse(const Duration(milliseconds: 1));
        expect(repository.requests.length, 3);
        expect(repository.requests.last.name, 'Rick');
        expect(repository.requests.last.pageNumber, 1);
        bloc.add(const CharactersSearchChanged('Morty'));
        async.flushMicrotasks();
        expect(repository.requests[2].token!.isCancelled, isTrue);
        async.elapse(const Duration(milliseconds: 350));
        repository.requests[3].completer.complete(page([10]));
        async.flushMicrotasks();
        repository.requests[1].completer.complete(page([2]));
        repository.requests[2].completer.complete(page([3]));
        async.flushMicrotasks();
        expect(bloc.state.query, 'Morty');
        expect((bloc.state as CharactersLoaded).characters.single.id, 10);
        bloc.add(const CharactersSearchChanged(''));
        async.flushMicrotasks();
        async.elapse(Duration.zero);
        expect(repository.requests.last.name, '');
        repository.requests.last.completer.complete(page([]));
        async.flushMicrotasks();
        expect(bloc.state, const CharactersEmpty(query: ''));
        bloc.close();
        async.flushMicrotasks();
      });
    },
  );
}
