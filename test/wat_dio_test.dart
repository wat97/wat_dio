import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wat_dio/wat_dio.dart';

void main() {
  group('RestService auth behavior', () {
    test('can be created without refreshToken', () async {
      final adapter = _RecordingAdapter([
        const _PlannedResponse(statusCode: 200, body: {'ok': true}),
      ]);

      final dio = _buildDio(adapter);

      final service = RestService(
        dioClient: dio,
        expiredToken: (response, handler) async {
          handler.next(response);
        },
      );

      final result = await service.get<Map<String, dynamic>>(endpoint: '/ping');

      expect(result.statusCode, 200);
      expect(result.body['ok'], isTrue);
      expect(adapter.requests, hasLength(1));
    });

    test('get retries once after 401 with refreshed token', () async {
      final adapter = _RecordingAdapter([
        const _PlannedResponse(statusCode: 401, body: {'message': 'expired'}),
        const _PlannedResponse(statusCode: 200, body: {'ok': true}),
      ]);

      final dio = _buildDio(adapter);
      var refreshCalls = 0;

      final service = RestService(
        dioClient: dio,
        idToken: 'old-token',
        refreshToken: () async {
          refreshCalls++;
          return 'new-token';
        },
        expiredToken: (response, handler) async {
          handler.next(response);
        },
      );

      final result =
          await service.get<Map<String, dynamic>>(endpoint: '/profile');

      expect(result.statusCode, 200);
      expect(result.body['ok'], isTrue);
      expect(refreshCalls, 1);
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.first.headers['Authorization'],
        'Bearer old-token',
      );
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-token',
      );
      expect(
          adapter.requests.last.uri.toString(), 'https://example.com/profile');
    });

    test('post retries once after 401 with refreshed token', () async {
      final adapter = _RecordingAdapter([
        const _PlannedResponse(statusCode: 401, body: {'message': 'expired'}),
        const _PlannedResponse(statusCode: 200, body: {'saved': true}),
      ]);

      final dio = _buildDio(adapter);
      var refreshCalls = 0;

      final service = RestService(
        dioClient: dio,
        idToken: 'old-token',
        refreshToken: () async {
          refreshCalls++;
          return 'new-token';
        },
        expiredToken: (response, handler) async {
          handler.next(response);
        },
      );

      final result = await service.post<Map<String, dynamic>>(
        endpoint: '/profile',
        data: {'name': 'wat'},
      );

      expect(result.statusCode, 200);
      expect(result.body['saved'], isTrue);
      expect(refreshCalls, 1);
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.data, {'name': 'wat'});
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-token',
      );
    });

    test('expiredToken is called when refresh token is empty', () async {
      final adapter = _RecordingAdapter([
        const _PlannedResponse(statusCode: 401, body: {'message': 'expired'}),
      ]);

      final dio = _buildDio(adapter);
      var expiredCalled = false;

      final service = RestService(
        dioClient: dio,
        idToken: 'old-token',
        refreshToken: () async => '',
        expiredToken: (response, handler) async {
          expiredCalled = true;
          handler.next(response);
        },
      );

      final result =
          await service.get<Map<String, dynamic>>(endpoint: '/profile');

      expect(expiredCalled, isTrue);
      expect(result.statusCode, 401);
      expect(adapter.requests, hasLength(1));
    });
  });
}

Dio _buildDio(HttpClientAdapter adapter) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://example.com',
      validateStatus: (value) => value != null && value < 500,
    ),
  )..httpClientAdapter = adapter;
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(List<_PlannedResponse> responses)
      : _responses = Queue.of(responses);

  final Queue<_PlannedResponse> _responses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      options.copyWith(
        headers: Map<String, dynamic>.from(options.headers),
        extra: Map<String, dynamic>.from(options.extra),
      ),
    );

    final response = _responses.removeFirst();
    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        ...response.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _PlannedResponse {
  const _PlannedResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final Object? body;
  final Map<String, List<String>> headers;
}
