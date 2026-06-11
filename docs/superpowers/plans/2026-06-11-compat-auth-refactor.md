# Compatibility-Safe Auth Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve auth refresh internals and docs without breaking the current public API used by existing consumers.

**Architecture:** Keep `RestService`, `WatInterceptor`, and callback signatures stable. Move retry to same configured `Dio` instance, gate interceptor installation on `refreshToken`, and verify behavior through deterministic adapter-backed tests.

**Tech Stack:** Flutter, Dart, Dio 5, flutter_test

---

### Task 1: Replace flaky network tests with deterministic adapter tests

**Files:**
- Modify: `test/wat_dio_test.dart`
- Check: `lib/src/rest_service.dart`
- Check: `lib/src/wat_interceptor.dart`

- [ ] **Step 1: Write failing tests for safe construction and retry behavior**

Add tests that assert:

- `RestService` can be created without `refreshToken`
- `get()` retries once after `401`
- `post()` retries once after `401`
- empty refresh token triggers `expiredToken`

- [ ] **Step 2: Run test suite to verify failures**

Run: `flutter test`
Expected: FAIL because current implementation crashes or keeps inconsistent behavior.

- [ ] **Step 3: Build fake adapter support in test file**

Add private fake adapter types that queue responses and capture request options so tests can assert retry behavior without external network.

- [ ] **Step 4: Re-run targeted tests**

Run: `flutter test test/wat_dio_test.dart`
Expected: FAIL only on intended auth behavior gaps.

### Task 2: Make `RestService` compatibility-safe

**Files:**
- Modify: `lib/src/rest_service.dart`
- Test: `test/wat_dio_test.dart`

- [ ] **Step 1: Install auth interceptor only when refresh callback exists**

Keep constructor signature unchanged, but remove non-null assertion path.

- [ ] **Step 2: Make `post()` use `handleRefreshToken(...)`**

Align retry behavior across request methods.

- [ ] **Step 3: Run targeted tests**

Run: `flutter test test/wat_dio_test.dart`
Expected: remaining failures only in retry implementation details.

### Task 3: Retry through original `Dio`

**Files:**
- Modify: `lib/src/wat_interceptor.dart`
- Test: `test/wat_dio_test.dart`

- [ ] **Step 1: Convert interceptor to use original client**

Pass original `Dio` into interceptor and reuse it for retries.

- [ ] **Step 2: Preserve request options while updating auth header**

Retry using copied request options and existing config rather than `Dio()` fresh instance.

- [ ] **Step 3: Run targeted tests**

Run: `flutter test test/wat_dio_test.dart`
Expected: PASS

### Task 4: Update docs to match new behavior

**Files:**
- Modify: `README.md`
- Modify: `docs/auth-flow.md`
- Modify: `docs/api-reference.md`

- [ ] **Step 1: Update behavior notes**

Document that `refreshToken` is optional for construction, and auto-refresh is enabled only when callback is supplied.

- [ ] **Step 2: Document consistent retry coverage**

Document `post()` alongside other request methods.

- [ ] **Step 3: Re-read docs for contradictions**

Check README and docs align with code behavior.

### Task 5: Final verification

**Files:**
- Check: `lib/src/rest_service.dart`
- Check: `lib/src/wat_interceptor.dart`
- Check: `test/wat_dio_test.dart`
- Check: `README.md`
- Check: `docs/auth-flow.md`
- Check: `docs/api-reference.md`

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: PASS

- [ ] **Step 2: Run formatting if needed**

Run: `dart format lib test docs`
Expected: files formatted, no semantic changes

- [ ] **Step 3: Review git diff**

Run: `git diff --stat`
Expected: only intended library, test, and doc changes

### Task 6: Audit Dio version floor before next release

**Files:**
- Modify: `pubspec.yaml`
- Modify: `docs/roadmap.md`
- Check: `test/wat_dio_test.dart`

- [ ] **Step 1: Inspect currently resolved `dio` version**

Run: `flutter pub deps | grep dio`
Expected: see exact `dio` 5.x version currently resolved in workspace or consuming app.

- [ ] **Step 2: Verify package behavior against latest supported `dio` 5.x**

Run: `flutter test`
Expected: PASS with latest resolved `dio` in major version 5.

- [ ] **Step 3: Decide minimum version policy**

If latest `dio` 5.x passes cleanly, choose one:

- keep `dio: ^5.1.2` to maximize consumer compatibility
- raise minimum to newer `5.x` only if package depends on newer fixes or APIs

- [ ] **Step 4: Document decision**

Update `docs/roadmap.md` and, if needed, `pubspec.yaml` with chosen minimum-version policy and rationale.
