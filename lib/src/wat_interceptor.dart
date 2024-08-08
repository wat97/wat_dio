import 'dart:io';

import 'package:wat_dio/wat_dio.dart';

class WatInterceptor implements InterceptorsWrapper {
  Future<String> Function() refreshToken;
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
        String tokenJWT = await refreshToken();
        if (tokenJWT.isEmpty) {
          await expiredToken(response, handler);
        } else {
          await retryHit(response, handler, tokenJWT);
        }
        break;
      case HttpStatus.forbidden:
      case HttpStatus.notAcceptable:
        await expiredToken(response, handler);
        break;
      default:
        return handler.next(response);
    }
  }

  Future<void> retryHit(
    Response response,
    ResponseInterceptorHandler handler,
    String token,
  ) async {
    response.requestOptions.headers.addAll(
      {
        'Authorization': 'Bearer $token',
      },
    );

    final opts = Options(
      method: response.requestOptions.method,
      headers: response.requestOptions.headers,
      followRedirects: response.requestOptions.followRedirects,
      extra: response.requestOptions.extra,
      contentType: response.requestOptions.contentType,
      validateStatus: response.requestOptions.validateStatus,
    );

    FormData formData = FormData();
    if (response.requestOptions.data is FormData) {
      formData.fields.addAll(response.requestOptions.data.fields);
      for (MapEntry mapFile in response.requestOptions.data.files) {
        formData.files.add(
          MapEntry(
            mapFile.key,
            MultipartFile.fromFileSync(
              mapFile.value.FILE_PATH,
              filename: mapFile.value.filename,
            ),
          ),
        );
        response.requestOptions.data = formData;
      }
    }

    // print("cloneReq Before ${formData.fields}");
    final cloneReq = await Dio().request(
      response.requestOptions.path,
      options: opts,
      data: formData,
      queryParameters: response.requestOptions.queryParameters,
    );
    return handler.resolve(cloneReq);
  }
}
