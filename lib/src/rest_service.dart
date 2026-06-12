import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wat_dio/src/wat_interceptor.dart';

import 'model/model.dart';
import 'typedefs.dart';

class RestService {
  /// Internal [Dio] client used for all requests.
  final Dio _dio;
  final Future<String> Function()? refreshToken;
  Future<void> Function(Response response, ResponseInterceptorHandler handler)
      expiredToken;
  final bool _hasRefreshInterceptor;

  String? _idToken;

  RestService({
    required Dio dioClient,
    required this.expiredToken,
    this.refreshToken,
    String? idToken,
    Iterable<Interceptor>? interceptors,
    HttpClientAdapter? httpClientAdapter,
  })  : _dio = dioClient,
        _hasRefreshInterceptor = refreshToken != null,
        _idToken = idToken {
    if (interceptors != null) _dio.interceptors.addAll(interceptors);
    if (httpClientAdapter != null) _dio.httpClientAdapter = httpClientAdapter;
    if (refreshToken != null) {
      _dio.interceptors.add(
        WatInterceptor(
          dio: _dio,
          refreshToken: refreshToken!,
          expiredToken: expiredToken,
          onRefreshSuccess: (token) {
            _idToken = token;
            _dio.options.headers.addAll(_headers);
          },
        ),
      );
    }
  }

  JSON get _headers => {
        if (_idToken != null) 'Authorization': 'Bearer $_idToken',
      };

  /// Sends a `GET` request to [endpoint] and returns a typed [RestModel].
  ///
  /// Use [queryParams] to send query string values.
  /// Use [options] to override request configuration.
  /// Use [onReceiveProgress] to observe response download progress.
  Future<RestModel<R>> get<R>({
    required String endpoint,
    JSON? queryParams,
    Options? options,
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    return handleRefreshToken(sendRequest: () async {
      _dio.options.headers.addAll(_headers);
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
      return RestModel<R>.fromJson(response);
    });
  }

  /// Sends a `POST` request to [endpoint] and returns a typed [RestModel].
  ///
  /// Use [data] to provide request body content.
  /// Use [queryParams] to send query string values.
  /// Use [options] to override request configuration.
  /// Use [onSendProgress] to observe upload progress.
  Future<RestModel<R>> post<R>({
    required String endpoint,
    Object? data,
    JSON? queryParams,
    Options? options,
    void Function(int count, int total)? onSendProgress,
  }) async {
    return handleRefreshToken(sendRequest: () async {
      _dio.options.headers.addAll(_headers);
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParams,
        options: options,
        onSendProgress: onSendProgress,
      );

      return RestModel<R>.fromJson(response);
    });
  }

  /// Sends a `PUT` request to [endpoint] and returns a typed [RestModel].
  ///
  /// Use [data] to provide request body content.
  /// Use [queryParams] to send query string values.
  /// Use [options] to override request configuration.
  /// Use [onSendProgress] to observe upload progress.
  Future<RestModel<R>> put<R>({
    required String endpoint,
    Object? data,
    JSON? queryParams,
    Options? options,
    void Function(int count, int total)? onSendProgress,
  }) async {
    return handleRefreshToken(sendRequest: () async {
      _dio.options.headers.addAll(_headers);
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParams,
        options: options,
        onSendProgress: onSendProgress,
      );

      return RestModel<R>.fromJson(response);
    });
  }

  /// Sends a `PATCH` request to [endpoint] and returns a typed [RestModel].
  ///
  /// Use [data] to provide request body content.
  /// Use [queryParams] to send query string values.
  /// Use [options] to override request configuration.
  /// Use [onSendProgress] to observe upload progress.
  Future<RestModel<R>> patch<R>({
    required String endpoint,
    Object? data,
    JSON? queryParams,
    Options? options,
    void Function(int count, int total)? onSendProgress,
  }) async {
    return handleRefreshToken(sendRequest: () async {
      _dio.options.headers.addAll(_headers);
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParams,
        options: options,
        onSendProgress: onSendProgress,
      );

      return RestModel<R>.fromJson(response);
    });
  }

  /// Sends a `DELETE` request to [endpoint] and returns a typed [RestModel].
  ///
  /// Use [data] to provide request body content when your API supports it.
  /// Use [queryParams] to send query string values.
  /// Use [options] to override request configuration.
  Future<RestModel<R>> delete<R>({
    required String endpoint,
    Object? data,
    JSON? queryParams,
    Options? options,
  }) async {
    return handleRefreshToken(sendRequest: () async {
      _dio.options.headers.addAll(_headers);
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParams,
        options: options,
      );

      return RestModel<R>.fromJson(response);
    });
  }

  /// Sends a `DOWNLOAD` request to [endpoint] and returns a typed [RestModel].
  ///
  /// Use [savePath] to choose where downloaded content is written.
  /// Use [queryParams] to send query string values.
  /// Use [options] to override request configuration.
  /// Use [onReceiveProgress] to observe download progress.
  Future<RestModel<R>> download<R>({
    required String endpoint,
    required dynamic savePath,
    JSON? queryParams,
    Options? options,
    void Function(int count, int total)? onReceiveProgress,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
  }) async {
    return handleRefreshToken(
      sendRequest: () async {
        _dio.options.headers.addAll(_headers);
        final response = await _dio.download(
          endpoint,
          savePath,
          queryParameters: queryParams,
          options: options,
          onReceiveProgress: onReceiveProgress,
          lengthHeader: lengthHeader,
          data: data,
          deleteOnError: deleteOnError,
        );
        return RestModel<R>.fromJson(response);
      },
    );
  }

  /// Replays [sendRequest] one time when a `401` needs refresh handling.
  ///
  /// This fallback is used only when automatic interceptor-based refresh is not
  /// installed for current service instance.
  Future<RestModel<R>> handleRefreshToken<R>({
    required Future<RestModel<R>> Function() sendRequest,
  }) async {
    final response = await sendRequest();
    if (response.statusCode == HttpStatus.unauthorized &&
        refreshToken != null &&
        !_hasRefreshInterceptor) {
      _idToken = await refreshToken!();
      if (_idToken == null || _idToken!.isEmpty) {
        return response;
      }
      _dio.options.headers.addAll(_headers);
      return await sendRequest();
    }
    return response;
  }
}
