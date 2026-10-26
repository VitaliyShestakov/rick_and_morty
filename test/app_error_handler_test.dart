import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:rick_and_morty/app/bootstrap/app_error_handler.dart';
import 'package:rick_and_morty/core/logging/app_logger.dart';

class _MemoryOutput extends LogOutput {
  final events = <LogEvent>[];

  @override
  void output(OutputEvent event) => events.add(event.origin);
}

void main() {
  late _MemoryOutput output;
  late AppLogger logger;
  late AppErrorHandler handler;

  setUp(() {
    output = _MemoryOutput();
    logger = AppLogger(output: output);
    handler = AppErrorHandler(logger);
  });

  tearDown(() => logger.close());

  test(
    'guarded zone records synchronous and asynchronous uncaught errors',
    () async {
      final synchronous = StateError('Synchronous failure');
      runZonedGuarded<void>(() => throw synchronous, handler.onZoneError);
      expect(output.events.single.error, same(synchronous));
      expect(output.events.single.stackTrace, isNotNull);

      final asynchronous = StateError('Asynchronous failure');
      final handled = Completer<void>();
      runZonedGuarded<void>(() => scheduleMicrotask(() => throw asynchronous), (
        error,
        stackTrace,
      ) {
        handler.onZoneError(error, stackTrace);
        handled.complete();
      });
      await handled.future;
      expect(output.events, hasLength(2));
      expect(output.events.last.error, same(asynchronous));
      expect(
        output.events.every((event) => event.level == Level.error),
        isTrue,
      );
    },
  );

  test(
    'Flutter and platform hooks preserve the exception and its stack trace',
    () {
      final previousFlutterHandler = FlutterError.onError;
      final previousPlatformHandler = PlatformDispatcher.instance.onError;
      addTearDown(() {
        FlutterError.onError = previousFlutterHandler;
        PlatformDispatcher.instance.onError = previousPlatformHandler;
      });
      handler.install();

      final error = StateError('Rendering failure');
      final stackTrace = StackTrace.current;
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      expect(output.events.single.error, same(error));
      expect(output.events.single.stackTrace, same(stackTrace));

      final platformError = StateError('Platform failure');
      expect(
        PlatformDispatcher.instance.onError!(platformError, stackTrace),
        isTrue,
      );
      expect(output.events.last.error, same(platformError));
      expect(output.events.last.stackTrace, same(stackTrace));
    },
  );

  test(
    'production threshold retains errors while filtering debug messages',
    () async {
      final releaseOutput = _MemoryOutput();
      final releaseLogger = AppLogger(
        output: releaseOutput,
        level: Level.warning,
      );
      addTearDown(releaseLogger.close);
      releaseLogger.debug('Debug message');
      releaseLogger.info('Info message');
      final error = StateError('Failure');
      releaseLogger.error(
        'Application failure',
        error: error,
        stackTrace: StackTrace.current,
      );
      expect(releaseOutput.events, hasLength(1));
      expect(releaseOutput.events.single.level, Level.error);
      expect(releaseOutput.events.single.error, same(error));
    },
  );
}
