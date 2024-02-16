import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wat_dio/model/model.dart';
import 'package:wat_dio/model/result_model.dart';
import 'package:wat_dio/wat_dio.dart';

void main() {
  test('Test Refresh Token ', () async {
    String baseApi = "https://rickandmortyapi.com/api";
    BaseOptions dioOptions = BaseOptions(
      baseUrl: baseApi,
    );

    String tokenJWT =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MDgwNTY5MjIsImV4cCI6MTcwODA1Njk5NCwiZGF0YSI6eyJpZF9taXRyYSI6IjEiLCJpZF90b2tvIjoiNiIsInBhcmVudF9pZCI6IjEiLCJ1c2VyX2lkIjoiNDIxIiwidXNlciI6InBlcnNvbmFsIiwiZnVsbG5hbWUiOiJGYWphciIsInN0YXR1cyI6ImFjdGl2ZSIsInVzZXJfdHlwZSI6InRva28iLCJuYW1hX3RlIjoiVGVzIFRva28gRU5CIiwiYWxhbWF0X3RlIjoiSmwuIFdpamF5YSBJSSBCbG9rIEIgUGVyc2lsIE5vLiA0LCBQdWxvLCBLZWJheW9yYW4gQmFydSIsImxhbmd1YWdlIjoiZW4iLCJ0cmFkaXRpb25hbCI6Im4iLCJ0YWtzaXJpbiI6Im4iLCJ0YWtzaXJpbl93aGl0ZWxpc3RlZCI6ZmFsc2V9fQ.B6rUKqTI4x46CEV74sDv0giRi0VsysdBduh70SVKQHI";
    String refresh =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MDgwNTY5MjIsImRhdGEiOnsidXNlcl9pZCI6IjQyMSIsInJhbmRvbSI6NjUyNjQ5fX0.XKhKJEzo4v0wi4yxVZhvqkILsBaTWf8Dq8wtQQe50W4";
    String urlRefresh = "https://api.my.enbmobile.asia/api/token/refresh";
    var formDataRefresh = FormData.fromMap(
      {
        "token": refresh,
      },
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: baseApi,
        validateStatus: (value) {
          return value! < 500;
        },
      ),
    );
    var service = RestService(
      dioClient: dio,
      idToken: tokenJWT,
      refreshToken: () async {
        var result = await Dio().post(
          urlRefresh,
          data: formDataRefresh,
          options: Options(
            validateStatus: (status) {
              return true;
            },
          ),
        );
        print("resultRefresh ${result.data}");
        // final model = ModelBaseApiV2.fromJson(result.data);
        // var tokenNew = "";
        // if (model.success) {
        //   tokenNew = model.data['token'];
        // }
        return "tokenNew";
      },
    );
    var formData = FormData.fromMap(
      {
        "language": "en",
      },
    );
    var result = await service.post(
      endpoint: "https://api.my.enbmobile.asia/api/user/language",
      data: formData,
    );
    print("Test Refresh Token ${result.toJson()}");
  });
}
