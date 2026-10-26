import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty/app/di/app_dependencies.dart';
import 'package:rick_and_morty/app/startup/app_startup.dart';
import 'package:rick_and_morty/core/logging/app_logger.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/screens/character_details_screen.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character/character_card.dart';
import 'package:rick_and_morty/shared/shared.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'live API: catalogue, search, details, pagination and empty results',
    (tester) async {
      await tester.pumpWidget(
        RepositoryProvider<AppLogger>(
          create: (_) => AppLogger(),
          dispose: (logger) => logger.close(),
          child: const AppDependencies(child: RickAndMortyApp()),
        ),
      );
      await tester.pump();
      await binding.takeScreenshot('splash');

      CharactersBloc bloc() =>
          tester.element(find.byType(AppStartup)).read<CharactersBloc>();

      Future<void> waitFor(bool Function() condition) async {
        for (var attempt = 0; attempt < 300; attempt++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (condition()) return;
        }
        fail(
          'The application did not reach the expected state within 30 seconds. '
          'Last state: ${bloc().state.runtimeType}, query: ${bloc().state.query}',
        );
      }

      await waitFor(() => bloc().state is CharactersLoaded);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('catalogue');

      final search = find.byKey(const ValueKey('character-search'));
      await tester.tap(search);
      await tester.pumpAndSettle();
      await tester.enterText(search, 'NoSuchCharacter123');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await waitFor(() => bloc().state is CharactersEmpty);
      await tester.pumpAndSettle();
      expect(find.text('Никого не нашли'), findsOneWidget);
      await binding.takeScreenshot('empty');
      await tester.tap(search);
      await tester.pumpAndSettle();
      await tester.enterText(search, 'Rick');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await waitFor(
        () => bloc().state is CharactersLoaded && bloc().state.query == 'Rick',
      );
      await tester.pumpAndSettle();
      await binding.takeScreenshot('search');

      final first = find.byType(CharacterCard).hitTestable().first;
      final selected = tester.widget<CharacterCard>(first).character;
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(find.byType(CharacterDetailsScreen), findsOneWidget);
      expect(find.text(selected.name), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.getTopLeft(find.text('Досье персонажа')).dy,
        greaterThanOrEqualTo(
          tester.view.padding.top / tester.view.devicePixelRatio,
        ),
      );
      await binding.takeScreenshot('details');
      await tester.tap(find.byTooltip('Назад'));
      await tester.pumpAndSettle();
      expect(tester.widget<AppSearchField>(search).controller.text, 'Rick');

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2600));
      await tester.pump();
      await waitFor(
        () =>
            bloc().state is CharactersLoaded &&
            (bloc().state as CharactersLoaded).characters.length > 20,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Наверх'));
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(scrollable.position.pixels, 0);
      expect(tester.widget<AppSearchField>(search).controller.text, 'Rick');
    },
  );
}
