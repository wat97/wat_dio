# Roadmap

This roadmap focuses on documentation quality and auth-flow reliability.

## Documentation Goals

### Short Term

- keep `README.md` optimized for pub.dev scanning
- keep examples runnable and minimal
- document actual behavior, not intended behavior
- cross-link package docs from README

### Mid Term

- add real example for login, refresh, and logout
- document multipart upload retry behavior
- add diagrams for request and refresh lifecycle
- add versioned migration notes when behavior changes

### Long Term

- publish API docs with clearer callback contracts
- add advanced recipes for token storage and testing
- document supported and unsupported retry scenarios

## Codebase Goals That Affect Docs

Docs should evolve with code in these areas:

1. keep auth handling predictable and easy to reason about
2. preserve original `Dio` configuration during retry
3. strengthen test coverage around auth edge cases
4. expand example app into realistic auth demo
5. consider clearer internal separation between retry and session-expired handling

## Documentation Update Policy

Every auth-related change should update:

- `README.md` when user-facing behavior changes
- `docs/auth-flow.md` when callback or status handling changes
- `docs/api-reference.md` when signatures or guarantees change
- `docs/roadmap.md` when priorities change

## Suggested Next Work

- replace integration-only tests with deterministic unit tests
- upgrade example app from counter demo to auth demo
- add multipart retry regression tests
