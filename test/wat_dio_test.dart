import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
