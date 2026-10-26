import 'package:flutter/foundation.dart';
import 'package:rick_and_morty/core/logging/app_logger.dart';

final class AppErrorHandler {
  AppErrorHandler(this._logger);

  final AppLogger _logger;

  void install() {
    FlutterError.onError = onFlutterError;
    PlatformDispatcher.instance.onError = onPlatformError;
  }

  void onFlutterError(FlutterErrorDetails details) => _logger.error(
    'Flutter framework error${details.library == null ? '' : ' in ${details.library}'}',
    error: details.exception,
    stackTrace: details.stack ?? StackTrace.current,
  );

  bool onPlatformError(Object error, StackTrace stackTrace) {
    _logger.error(
      'Unhandled platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  }

  void onZoneError(Object error, StackTrace stackTrace) => _logger.error(
    'Unhandled application error',
    error: error,
    stackTrace: stackTrace,
  );
}
