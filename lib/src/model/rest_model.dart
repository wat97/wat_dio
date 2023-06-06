import 'package:dio/dio.dart';

import '../typedefs.dart';

class RestModel<T> {
  final JSON headersModel;
  final T body;
  final int statusCode;
  const RestModel({
    required this.headersModel,
    required this.body,
    required this.statusCode,
  });

  factory RestModel.fromJson(Response response) {
    JSON headersJson = {};
    response.headers.forEach((name, values) {
      headersJson.addAll({name: values});
    });
    return RestModel(
      headersModel: headersJson,
      body: response.data as T,
      statusCode: response.statusCode ?? 404,
    );
  }

  JSON toJson() {
    JSON data = {
      "headers": headersModel,
      "body": body,
      "status_code": statusCode,
    };
    return data;
  }
}
