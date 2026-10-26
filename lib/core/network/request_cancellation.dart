import 'dart:async';

final class RequestCancelled implements Exception {
  const RequestCancelled();
}

final class RequestCancellation {
  final _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!isCancelled) _cancelled.complete();
  }
}
