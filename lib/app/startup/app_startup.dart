import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/app/startup/splash_screen.dart';
import 'package:rick_and_morty/features/characters/presentation/bloc/bloc.dart';
import 'package:rick_and_morty/features/characters/presentation/screens/characters_screen.dart';
import 'package:rick_and_morty/shared/shared.dart';

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  late bool _ready;

  bool _isReady(CharactersState state) => switch (state) {
    CharactersInitial() || CharactersLoading() => false,
    _ => true,
  };

  @override
  void initState() {
    super.initState();
    _ready = _isReady(context.read<CharactersBloc>().state);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<CharactersBloc, CharactersState>(
        listenWhen: (_, state) => !_ready && _isReady(state),
        listener: (_, _) => setState(() => _ready = true),
        child: AnimatedSwitcher(
          duration: AppDurations.transition,
          child: _ready ? const CharactersScreen() : const SplashScreen(),
        ),
      );
}
