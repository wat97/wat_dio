# Architecture

`wat_dio` is structured as thin package over `dio`.

## Main Pieces

### `RestService`

File: `lib/src/rest_service.dart`

Responsibilities:

- hold configured `Dio` client
- manage optional in-memory `idToken`
- attach auth header before requests
- expose simple request methods
- wrap responses in `RestModel<T>`

Methods currently exposed:

- `get`
- `post`
- `put`
- `download`

### `WatInterceptor`

File: `lib/src/wat_interceptor.dart`

Responsibilities:

- inspect successful responses
- react to auth-related status codes
- call `refreshToken()`
- retry failed request when refresh succeeds
- call `expiredToken(...)` when refresh cannot recover session

### `RestModel<T>`

File: `lib/src/model/rest_model.dart`

Responsibilities:

- expose headers as `Map<String, dynamic>`
- expose raw response body as generic type `T`
- expose HTTP status code

## Current Request Lifecycle

1. Consumer creates `Dio`.
2. Consumer creates `RestService`.
3. `RestService` optionally adds interceptors and adapter to supplied `Dio`.
4. `RestService` installs `WatInterceptor`.
5. Request method adds bearer token header when token exists.
6. Response is wrapped into `RestModel<T>`.
7. If auth fails and `refreshToken` exists, interceptor handles one retry on same configured client.

## Design Trade-Offs In Current Version

Benefits:

- very small API surface
- easy adoption in apps already using `dio`
- auth callbacks stay under app control

Known trade-offs:

- refresh behavior depends on supplied callback
- retry logic stays on same configured `Dio` client
- request methods now share same auth contract
- token state is in memory only

## Recommended Future Direction

To simplify maintenance, future versions should converge toward one clear auth strategy:

1. keep retry logic in one layer only
2. reuse same configured `Dio` instance during retry
3. make callback contracts explicit and null-safe
4. document multipart retry guarantees
5. add deterministic tests around `401`, `403`, `406`, and refresh failure
