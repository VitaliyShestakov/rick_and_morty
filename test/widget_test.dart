import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty/app/startup/splash_screen.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/screens/character_details_screen.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character/character_card.dart';
import 'package:rick_and_morty/shared/shared.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('splash logo stays at screen centre while captions fade in', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 60, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const SplashScreen()),
    );
    final logo = find.byType(PortalMark);
    final caption = find.text('Rick and Morty');
    double opacity() => tester
        .widget<Opacity>(
          find.ancestor(of: caption, matching: find.byType(Opacity)).first,
        )
        .opacity;
    expect(tester.getCenter(logo), const Offset(215, 450));
    expect(tester.getSize(logo), const Size.square(144));
    expect(opacity(), 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(opacity(), inExclusiveRange(0, 1));
    expect(tester.getCenter(logo), const Offset(215, 450));
    await tester.pump(const Duration(milliseconds: 250));
    expect(opacity(), 1);
    expect(tester.getCenter(logo), const Offset(215, 450));
    expect(
      tester.getTopLeft(caption).dy,
      greaterThan(tester.getBottomLeft(logo).dy),
    );
    tester.view.physicalSize = const Size(640, 320);
    await tester.pump();
    expect(tester.getCenter(logo), const Offset(320, 160));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'returning from details preserves search, cards and scroll without fetching',
    (tester) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MemoryRepository();
      await tester.pumpWidget(
        RepositoryProvider<CharactersRepository>.value(
          value: repository,
          child: const RickAndMortyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('character-search')),
        'Rick',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final offset = scrollable.position.pixels;
      expect(offset, greaterThan(0));
      final calls = repository.requests.length;
      final card = find.byType(CharacterCard).hitTestable().first;
      final selected = tester.widget<CharacterCard>(card).character;
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(CharacterDetailsScreen), findsOneWidget);
      expect(find.text(selected.name), findsOneWidget);
      expect(find.text(selected.origin), findsOneWidget);
      expect(find.text(selected.location), findsOneWidget);
      await tester.tap(find.byTooltip('Назад'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AppSearchField>(
              find.byKey(
                const ValueKey('character-search'),
                skipOffstage: false,
              ),
            )
            .controller
            .text,
        'Rick',
      );
      expect(scrollable.position.pixels, closeTo(offset, 0.1));
      expect(repository.requests.length, calls);
      expect(find.byKey(ValueKey('character-${selected.id}')), findsOneWidget);
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('character-search')));
      await tester.enterText(
        find.byKey(const ValueKey('character-search')),
        'Morty',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(repository.requests.last.name, 'Morty');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'startup failure leaves splash and retry and search keep the catalogue',
    (tester) async {
      final repository = ControlledRepository();
      await tester.pumpWidget(
        RepositoryProvider<CharactersRepository>.value(
          value: repository,
          child: const RickAndMortyApp(),
        ),
      );
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(repository.requests, hasLength(1));
      repository.requests.first.completer.completeError(
        const CharactersFailure('Нет сети'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Нет сети'), findsOneWidget);
      await tester.tap(find.text('Попробовать снова'));
      await tester.pump();
      expect(find.byType(SplashScreen), findsNothing);
      repository.requests.last.completer.complete(page([1, 2]));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('character-search')),
        'Morty',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(SplashScreen), findsNothing);
      repository.requests.last.completer.complete(page([]));
      await tester.pumpAndSettle();
      expect(find.text('Никого не нашли'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('catalogue and details fit a narrow screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      RepositoryProvider<CharactersRepository>.value(
        value: MemoryRepository(),
        child: const RickAndMortyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('character-1')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('character-1')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
