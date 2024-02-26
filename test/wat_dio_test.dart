import 'package:flutter_test/flutter_test.dart';
import 'package:wat_dio/wat_dio.dart';

void main() {
  test('Test Api', () async {
    String baseApi = "https://rickandmortyapi.com/api";
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
      expiredToken: (response, handler) async {},
    );
    var result = await service.get(
      endpoint: "",
      onReceiveProgress: (p0, p1) {},
    );
    expect(result, isNotNull);
  });

  test('Test Refresh Token ', () async {
    String baseApi = "https://rickandmortyapi.com/api";
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
      expiredToken: (response, handler) async {},
    );
    var result = await service.get(
      endpoint: "",
      onReceiveProgress: (p0, p1) {},
    );
    expect(result, isNotNull);
  });

  test('Test Degress ', () async {
    String baseApi = "https://api.3degrees.app/";
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
      expiredToken: (response, handler) async {},
    );
    var result = await service.get(
      endpoint: "campaigns",
    );
    expect(result, isNotNull);
  });
}
