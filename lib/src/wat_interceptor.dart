import 'dart:io';

import 'package:wat_dio/wat_dio.dart';

const _retryAttemptedKey = '_watDioRetryAttempted';

class WatInterceptor extends Interceptor {
  WatInterceptor({
    required this.dio,
    required this.refreshToken,
    required this.expiredToken,
    this.onRefreshSuccess,
  });

  final Dio dio;
  final Future<String> Function() refreshToken;
  final Future<void> Function(
    Response response,
    ResponseInterceptorHandler handler,
  ) expiredToken;
  final void Function(String token)? onRefreshSuccess;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    switch (response.statusCode) {
      case HttpStatus.unauthorized:
        if (response.requestOptions.extra[_retryAttemptedKey] == true) {
          await expiredToken(response, handler);
          return;
        }

        final tokenJWT = await refreshToken();
        if (tokenJWT.isEmpty) {
          await expiredToken(response, handler);
          return;
        }

        onRefreshSuccess?.call(tokenJWT);
        await retryHit(response, handler, tokenJWT);
        return;
      case HttpStatus.forbidden:
      case HttpStatus.notAcceptable:
        await expiredToken(response, handler);
        return;
      default:
        handler.next(response);
    }
  }

  Future<void> retryHit(
    Response response,
    ResponseInterceptorHandler handler,
    String token,
  ) async {
    final requestOptions = response.requestOptions.copyWith(
      data: _cloneData(response.requestOptions.data),
      headers: {
        ...response.requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
      extra: {
        ...response.requestOptions.extra,
        _retryAttemptedKey: true,
      },
    );

    final cloneReq = await dio.fetch<dynamic>(requestOptions);
    handler.resolve(cloneReq);
  }

  dynamic _cloneData(dynamic data) {
    if (data is! FormData) return data;

    final formData = FormData();
    formData.fields.addAll(data.fields);
    for (final entry in data.files) {
      formData.files.add(
        MapEntry(
          entry.key,
          entry.value.clone(),
        ),
      );
    }
    return formData;
  }
}
