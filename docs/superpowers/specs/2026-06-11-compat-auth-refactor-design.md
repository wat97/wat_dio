# Compatibility-Safe Auth Refactor Design

## Goal

Improve internal auth refresh behavior in `wat_dio` without breaking existing consumers that already depend on the current public API.

## Scope

In scope:

- keep all current public exports
- keep current constructor and callback signatures
- remove init-time crash when `refreshToken` is omitted
- make `post()` follow refresh path consistently
- retry through same configured `Dio` instance
- replace network-dependent tests with deterministic unit tests
- update docs to match real behavior

Out of scope:

- introducing a new public auth API
- deprecating current callbacks
- changing return types
- adding persistent token storage

## Compatibility Rules

1. `RestService` constructor shape must stay unchanged.
2. Existing code that passes `refreshToken` and `expiredToken` must keep compiling.
3. Existing request methods must keep names and generics unchanged.
4. Retry behavior may become more consistent, but not less capable.
5. New internal helpers are allowed if they stay private.

## Approach Options

### Option 1: Minimal internal patch

Patch current flow in place, keep interceptor, and add null-safe fallback.

Pros:

- smallest API risk
- easiest upgrade path
- least code churn

Cons:

- keeps some legacy structure

### Option 2: Add new internal auth coordinator

Introduce private helper to own retry and auth decisions while leaving public API intact.

Pros:

- cleaner separation
- easier long-term maintenance

Cons:

- slightly larger refactor

### Option 3: New public API plus legacy shim

Pros:

- cleanest public model

Cons:

- too much scope
- higher compatibility risk

## Recommended Design

Use Option 1 now.

Implementation shape:

- `RestService` only installs auth interceptor when `refreshToken` exists
- `post()` uses same `handleRefreshToken(...)` path as `get`, `put`, and `download`
- `WatInterceptor` extends `Interceptor` and receives original `Dio` instance
- retry uses original `dio.fetch(requestOptions)` path after updating headers
- form-data retry keeps current best-effort rebuild, but without losing client config

## Error Handling

- No `refreshToken`: no init crash, no auto-refresh
- Empty refreshed token: call `expiredToken(...)`
- `403` or `406`: call `expiredToken(...)`
- retry failure from `dio.fetch(...)`: let Dio surface error

## Testing Strategy

Use deterministic tests with fake `HttpClientAdapter`.

Cover:

- constructor without `refreshToken`
- `401` then refresh success on `get`
- `401` then refresh success on `post`
- `401` then refresh failure triggers `expiredToken`
- retry still uses same configured client and headers path

## Files

- Modify `lib/src/rest_service.dart`
- Modify `lib/src/wat_interceptor.dart`
- Replace `test/wat_dio_test.dart`
- Update `README.md`
- Update `docs/auth-flow.md`
- Update `docs/api-reference.md`
