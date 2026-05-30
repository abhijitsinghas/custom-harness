import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for AuthStateProvider (Riverpod) — covers US-1.4.5, US-1.4.17.
///
/// The provider is expected to live in lib/data/auth/auth_state_provider.dart.

void main() {
  group('AuthStateProvider — states (US-1.4.5)', () {
    test('should emit signedOut as initial state', () {
      fail('TODO(implementer): authStateProvider initial = AuthState.signedOut');
    });

    test('should emit signedIn(account) on successful sign-in', () async {
      fail('TODO(implementer): Sign-in transition');
    });

    test('should emit signedOut on explicit sign-out', () async {
      fail('TODO(implementer): Sign-out transition');
    });

    test('should emit skipped when user chooses offline mode', () async {
      fail('TODO(implementer): Skip transition');
    });

    test('should include displayName and email in signedIn state', () async {
      fail('TODO(implementer): Account data in state');
    });
  });

  group('AuthStateProvider — persistence', () {
    test('should persist auth state across app restarts', () async {
      fail('TODO(implementer): SharedPreferences persistence');
    });

    test('should restore signedIn on relaunch without re-auth', () async {
      fail('TODO(implementer): Silent restore');
    });

    test('should clear persisted state on sign-out', () async {
      fail('TODO(implementer): Clear on sign-out');
    });
  });

  group('AuthStateProvider — accessibility (US-1.4.17)', () {
    test('should provide semantic labels for auth state transitions', () async {
      fail('TODO(implementer): Accessible state change announcements');
    });
  });
}
