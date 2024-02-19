import 'dart:io';

import 'package:dio/dio.dart';
import 'package:wat_dio/src/wat_interceptor.dart';

import 'model/model.dart';
import 'typedefs.dart';

class RestService {
  /// [Dio] client
  final Dio _dio;
  final Future<String> Function()? refreshToken;
  Future<void> Function(Response response, ResponseInterceptorHandler handler)
      expiredToken;

  String? _idToken;

  RestService({
    required Dio dioClient,
    required this.expiredToken,
    this.refreshToken,
    String? idToken,
    Iterable<Interceptor>? interceptors,
    HttpClientAdapter? httpClientAdapter,
  })  : _dio = dioClient,
        _idToken = idToken {
    if (interceptors != null) _dio.interceptors.addAll(interceptors);
    if (httpClientAdapter != null) _dio.httpClientAdapter = httpClientAdapter;
    _dio.interceptors.add(WatInterceptor(
      refreshToken: refreshToken!,
      expiredToken: expiredToken,
    ));
  }

  JSON get _headers => {
        if (_idToken != null) 'Authorization': 'Bearer $_idToken',
      };

  /// This method sends a `GET` request to the [endpoint], **decodes**
  /// the response and returns a parsed [RestModel] with a body of type [R].
  ///
  /// Any errors encountered during the request are caught and a custom
  ///
  /// [queryParams] holds any query parameters for the request.
  ///
  /// [options] are special instructions that can be merged with the request.
  ///
  /// [onReceiveProgress] are To receive progress when receive api
  ///
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

  /// This method sends a `POST` request to the [endpoint], **decodes**
  /// the response and returns a parsed [RestModel] with a body of type [R].
  ///
  /// The [data] contains body for the request.
  ///
  /// [options] are special instructions that can be merged with the request.
  ///
  /// [onSendProgress] are To receive progress when upload api
  ///
  Future<RestModel<R>> post<R>({
    required String endpoint,
    Object? data,
    JSON? queryParams,
    Options? options,
    void Function(int count, int total)? onSendProgress,
  }) async {
    // return handleRefreshToken(sendRequest: () async {
    _dio.options.headers.addAll(_headers);
    final response = await _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParams,
      options: options,
      onSendProgress: onSendProgress,
    );

    return RestModel<R>.fromJson(response);
    // });
  }

  /// This method sends a `PUT` request to the [endpoint], **decodes**
  /// the response and returns a parsed [RestModel] with a body of type [R].
  ///
  /// The [data] contains body for the request.
  ///
  /// [options] are special instructions that can be merged with the request.
  ///
  /// [onSendProgress] are To receive progress when upload api
  ///
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

  /// This method to handle if token is expired
  /// the response and returns a parsed [RestModel] with a body of type [R].
  ///
  /// The [sendRequest] contains function to [post] or [get] method call before.
  ///
  Future<RestModel<R>> handleRefreshToken<R>({
    required Future<RestModel<R>> Function() sendRequest,
  }) async {
    final response = await sendRequest();
    if (response.statusCode == HttpStatus.unauthorized) {
      if (refreshToken != null) {
        _idToken = await refreshToken!();
        print(
            "handleRefresh ${response.body} (${response.statusCode}) (${HttpStatus.unauthorized}) [$_idToken] ");
        _dio.options.headers.addAll(_headers);
      }
      return await sendRequest();
    }
    return response;
  }
}
