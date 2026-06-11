# API Reference

## Import

```dart
import 'package:wat_dio/wat_dio.dart';
```

Package exports:

- `RestService`
- `RestModel<T>`
- `dio` classes from `package:dio/dio.dart`

## `RestService`

Constructor:

```dart
RestService({
  required Dio dioClient,
  required Future<void> Function(
    Response response,
    ResponseInterceptorHandler handler,
  ) expiredToken,
  Future<String> Function()? refreshToken,
  String? idToken,
  Iterable<Interceptor>? interceptors,
  HttpClientAdapter? httpClientAdapter,
})
```

### Parameters

#### `dioClient`

Configured `Dio` instance used for outgoing requests.

#### `expiredToken`

Callback for unrecoverable auth cases.

#### `refreshToken`

Callback for recovering from `401 Unauthorized`.

Important current behavior:

- package installs auth interceptor only when this callback is supplied
- omit it when you do not want automatic `401` refresh behavior

#### `idToken`

Initial access token used for bearer auth.

#### `interceptors`

Additional interceptors appended to supplied client before `WatInterceptor`.

#### `httpClientAdapter`

Optional adapter override for supplied `Dio` client.

## Methods

### `get<R>()`

```dart
Future<RestModel<R>> get<R>({
  required String endpoint,
  Map<String, dynamic>? queryParams,
  Options? options,
  void Function(int count, int total)? onReceiveProgress,
})
```

Sends GET request, wraps result in `RestModel<R>`, and uses service-level refresh handling.

### `post<R>()`

```dart
Future<RestModel<R>> post<R>({
  required String endpoint,
  Object? data,
  Map<String, dynamic>? queryParams,
  Options? options,
  void Function(int count, int total)? onSendProgress,
})
```

Sends POST request and wraps result in `RestModel<R>`.

### `put<R>()`

```dart
Future<RestModel<R>> put<R>({
  required String endpoint,
  Object? data,
  Map<String, dynamic>? queryParams,
  Options? options,
  void Function(int count, int total)? onSendProgress,
})
```

Sends PUT request, wraps result, and uses service-level refresh handling.

### `download<R>()`

```dart
Future<RestModel<R>> download<R>({
  required String endpoint,
  required dynamic savePath,
  Map<String, dynamic>? queryParams,
  Options? options,
  void Function(int count, int total)? onReceiveProgress,
  bool deleteOnError = true,
  String lengthHeader = Headers.contentLengthHeader,
  dynamic data,
})
```

Downloads remote content and wraps resulting response.

## `RestModel<T>`

```dart
class RestModel<T> {
  final Map<String, dynamic> headersModel;
  final T body;
  final int statusCode;
}
```

### Fields

#### `headersModel`

Response headers converted into map.

#### `body`

Raw `response.data` cast to `T`.

#### `statusCode`

HTTP status code. Falls back to `404` when response has no status code.

## Minimal Usage Example

```dart
final service = RestService(
  dioClient: Dio(BaseOptions(baseUrl: 'https://api.example.com')),
  idToken: token,
  refreshToken: () async => await refreshAccessToken(),
  expiredToken: (response, handler) async {
    handler.next(response);
  },
);

final profile = await service.get<Map<String, dynamic>>(
  endpoint: '/profile',
);
```
