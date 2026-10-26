import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rick_and_morty/app/startup/app_startup.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';
import 'package:rick_and_morty/shared/shared.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        CharactersBloc(repository: context.read<CharactersRepository>())
          ..add(const CharactersOpened()),
    child: MaterialApp(
      title: 'Rick and Morty',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.dark,
      home: const AppStartup(),
    ),
  );
}
