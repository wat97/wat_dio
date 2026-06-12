# Auth Flow

This document describes current auth behavior in `wat_dio` and recommended consumer expectations.

## Inputs From Consumer

`RestService` accepts:

- `dioClient`
- `idToken`
- `refreshToken`
- `expiredToken`

### `idToken`

Current bearer token used to populate request header:

```http
Authorization: Bearer <idToken>
```

### `refreshToken`

Async callback that should return:

- new access token when refresh succeeds
- empty string when session can no longer be refreshed

### `expiredToken`

Async callback used when auth is no longer valid.

Typical app behavior:

- clear local session
- remove stored tokens
- show login screen
- show auth-expired message

## Status-Code Handling

### `401 Unauthorized`

Current expected path:

1. request sent with current bearer token
2. server returns `401`
3. if `refreshToken` exists, package calls `refreshToken()`
4. if callback returns non-empty token, package retries request on same configured `Dio`
5. if callback returns empty token, package calls `expiredToken(...)`

### `403 Forbidden`

Current interceptor calls `expiredToken(...)`.

### `406 Not Acceptable`

Current interceptor calls `expiredToken(...)`.

## Current Implementation Notes

Auth refresh is driven by `WatInterceptor` when `refreshToken` is supplied.

`RestService` keeps request methods aligned so all main methods share same auth contract:

- `get`
- `post`
- `put`
- `download`

## Retry Semantics

When interceptor retries request:

- it updates request headers with new bearer token
- it rebuilds `Options`
- it reuses same configured `Dio` instance
- it resends request with copied method, headers, query params, and cloned form data when needed

Implication:

- base client configuration stays attached during retry
- adapter and client-level options stay attached during retry

## Guidance For Consumers

Use current release safely by following these rules:

1. provide `refreshToken` when you want automatic `401` recovery
2. keep `refreshToken` idempotent
3. return empty string only when session should end
4. keep `expiredToken` side effects explicit
5. test retry flow with your own `Dio` options and multipart requests
