import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/logging/app_logger.dart';

final class HttpLoggingInterceptor extends Interceptor {
  HttpLoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug('HTTP ${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      'HTTP ${response.statusCode} ${response.requestOptions.uri.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!CancelToken.isCancel(err) && err.response?.statusCode != 404) {
      _logger.warning(
        'HTTP ${err.requestOptions.method} ${err.requestOptions.uri.path}: '
        '${err.response?.statusCode ?? err.type.name}',
        error: err.message,
        stackTrace: err.stackTrace,
      );
    }
    handler.next(err);
  }
}
