import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/app/app.dart';
import 'package:rick_and_morty/app/bootstrap/app_bloc_observer.dart';
import 'package:rick_and_morty/app/bootstrap/app_error_handler.dart';
import 'package:rick_and_morty/app/di/app_dependencies.dart';
import 'package:rick_and_morty/core/logging/app_logger.dart';

void main() {
  final logger = AppLogger();
  final errorHandler = AppErrorHandler(logger);

  runZonedGuarded<void>(() {
    WidgetsFlutterBinding.ensureInitialized();
    errorHandler.install();
    Bloc.observer = AppBlocObserver(logger);
    logger.info('Starting Rick and Morty');
    runApp(
      RepositoryProvider<AppLogger>.value(
        value: logger,
        child: const AppDependencies(child: RickAndMortyApp()),
      ),
    );
  }, errorHandler.onZoneError);
}
