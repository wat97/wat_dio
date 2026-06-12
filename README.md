# wat_dio

[![Pub Version](https://img.shields.io/pub/v/wat_dio.svg)](https://pub.dev/packages/wat_dio)
[![License](https://img.shields.io/github/license/wat97/wat_dio.svg)](https://github.com/wat97/wat_dio/blob/main/LICENSE)

HTTP wrapper on top of `dio` for Flutter apps that need JWT bearer auth, refresh-token retry, and a small typed response model.

`wat_dio` is useful when your app already uses `dio` and you want one place to:

- attach bearer tokens
- retry requests after `401 Unauthorized`
- react to expired sessions with a callback
- return a simple `RestModel<T>` object

## Features

- `RestService` wrapper around `Dio`
- Auto-attach `Authorization: Bearer <token>` when `idToken` exists
- Refresh-token callback for expired access tokens
- Expired-session callback for unrecoverable auth states
- Typed `RestModel<T>` response wrapper for `get`, `post`, `put`, `patch`, `delete`, and `download`

## Installation

Add package to `pubspec.yaml`:

```yaml
dependencies:
  wat_dio: ^0.0.4
```

Then install dependencies:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:dio/dio.dart';
import 'package:wat_dio/wat_dio.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: 'https://api.example.com',
    validateStatus: (status) => status != null && status < 500,
  ),
);

final service = RestService(
  dioClient: dio,
  idToken: '<access-token>',
  refreshToken: () async {
    // Call your refresh endpoint here.
    // Return empty string when session can no longer be refreshed.
    return '<new-access-token>';
  },
  expiredToken: (response, handler) async {
    // Clear session, log out user, navigate to login, etc.
    handler.next(response);
  },
);

final result = await service.get<Map<String, dynamic>>(
  endpoint: '/profile',
);

print(result.statusCode);
print(result.body);

await service.patch<Map<String, dynamic>>(
  endpoint: '/profile',
  data: {
    'nickname': 'wat',
  },
);
```

## Auth Flow

`wat_dio` currently combines request handling in `RestService` with auth recovery in `WatInterceptor`.

1. `RestService` sends request with current bearer token when `idToken` exists.
2. If server returns `401` and `refreshToken` exists, package tries `refreshToken()`.
3. If refresh returns non-empty token, package retries request with new bearer token on same configured `Dio` client.
4. If refresh fails or auth state is unrecoverable, package calls `expiredToken(...)`.

See more:

- [Architecture](doc/architecture.md)
- [Auth flow](doc/auth-flow.md)
- [API reference](doc/api-reference.md)
- [Roadmap](doc/roadmap.md)

## API Overview

Public exports from package:

- `RestService`
- `RestModel<T>`
- `dio` types from `package:dio/dio.dart`

Main methods on `RestService`:

```dart
Future<RestModel<R>> get<R>({...})
Future<RestModel<R>> post<R>({...})
Future<RestModel<R>> put<R>({...})
Future<RestModel<R>> patch<R>({...})
Future<RestModel<R>> delete<R>({...})
Future<RestModel<R>> download<R>({...})
```

`RestModel<T>` shape:

```dart
class RestModel<T> {
  final Map<String, dynamic> headersModel;
  final T body;
  final int statusCode;
}
```

## Current Behavior Notes

This package works today, but current release behavior is important to understand before production use:

- `refreshToken` is optional. When omitted, requests still work but no automatic refresh happens on `401`.
- `get`, `post`, `put`, `patch`, `delete`, and `download` now follow same auth-refresh contract.
- Retry logic reuses same configured `Dio` client, so base URL, adapter, and client configuration stay intact.
- `expiredToken(...)` still owns unrecoverable auth behavior such as logout or session reset.

Those details are documented so consumers know current behavior, and so future changes can improve package consistency without surprise.

## Example

Small demo app lives in [`example/`](example).

Current example is minimal. Planned direction:

- mock login flow
- persisted access token
- simulated `401` -> refresh -> retry path
- expired session handling

## Contributing

When changing auth behavior, update docs in same pull request:

- `README.md`
- `doc/auth-flow.md`
- `doc/api-reference.md`
- `doc/roadmap.md`

## License

See [`LICENSE`](LICENSE).
