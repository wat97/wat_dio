import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wat_dio/model/model.dart';
import 'package:wat_dio/model/result_model.dart';
import 'package:wat_dio/wat_dio.dart';

void main() {
  test('Test Api', () async {
    String baseApi = "https://rickandmortyapi.com/api";
    BaseOptions dioOptions = BaseOptions(
      baseUrl: baseApi,
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
    );
    var result = await service.get(
      endpoint: "",
      onReceiveProgress: (p0, p1) {
        print("count $p0, total $p1");
      },
    );
    print(result.toJson());
  });

  test('Test Refresh Token ', () async {
    String baseApi = "https://rickandmortyapi.com/api";
    BaseOptions dioOptions = BaseOptions(
      baseUrl: baseApi,
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
    );
    var result = await service.get(
      endpoint: "",
      onReceiveProgress: (p0, p1) {
        print("count $p0, total $p1");
      },
    );
    print(result.toJson());
  });

  test('Test Degress ', () async {
    String baseApi = "https://api.3degrees.app/";
    BaseOptions dioOptions = BaseOptions(
      baseUrl: baseApi,
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
    );
    var result = await service.get(
      endpoint: "campaigns",
    );
    BaseModel baseModel = BaseModel.fromJson(result.body);
    List<ResultModel> listResult = [];
    for (var element in (baseModel.result as List)) {
      ResultModel modelElement =
          ResultModel.fromJson(json.decode(json.encode(element)));
      print("modelElement ${modelElement.title}");
    }
    // print(baseModel.success);
  });

  test('Test Get config ', () async {
    var listdata = [
      "MGJ53PA/A",
      "MGLN3LL/A",
      "MLK03PA/A",
      "MLL73PA/A",
      "MHDF3PA/A",
      "MGML3PA/A",
      "MKU92KH/A",
      "MKU92KHJA",
    ];

    String baseApi = "https://dev-app.tradeinplus.id/v1/api/config/get/";
    BaseOptions dioOptions = BaseOptions(
      baseUrl: baseApi,
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
    );
    var result = await service.get(
      endpoint: "",
      onReceiveProgress: (p0, p1) {
        print("count $p0, total $p1");
      },
    );
    String pattern = result.body['data']['apple_model_number_regex'];
    RegExp regExp = RegExp(pattern);
    // print("Check Last ${regExp.hasMatch(lastString)}");
    int keI = 0;
    listdata.forEach((elementData) {
      keI = keI + 1;
      var hasMatch = regExp.hasMatch(elementData);
      print("$keI. Pattern $pattern [$elementData] ($hasMatch)");
    });
  });
}
