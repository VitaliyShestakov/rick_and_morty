import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final class AppLogger {
  AppLogger({LogOutput? output, Level? level})
    : _logger = Logger(
        level: level ?? (kDebugMode ? Level.debug : Level.warning),
        filter: ProductionFilter(),
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          colors: false,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        output: output,
      );

  final Logger _logger;

  void debug(String message) => _logger.d(message);

  void info(String message) => _logger.i(message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  void error(
    String message, {
    required Object error,
    required StackTrace stackTrace,
  }) => _logger.e(message, error: error, stackTrace: stackTrace);

  Future<void> close() => _logger.close();
}
