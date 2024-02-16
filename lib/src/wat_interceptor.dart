import 'dart:io';

import 'package:wat_dio/wat_dio.dart';

class WatInterceptor implements InterceptorsWrapper {
  Future<void> Function(Response response, ResponseInterceptorHandler handler)
      refreshToken;
  Future<void> Function(Response response, ResponseInterceptorHandler handler)
      expiredToken;
  WatInterceptor({
    required this.refreshToken,
    required this.expiredToken,
  });
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    return handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    switch (response.statusCode) {
      case HttpStatus.unauthorized:
        await refreshToken(response, handler);
        break;
      case HttpStatus.forbidden:
      case HttpStatus.notAcceptable:
        await expiredToken(response, handler);
        break;
      default:
        return handler.next(response);
    }
  }
}
