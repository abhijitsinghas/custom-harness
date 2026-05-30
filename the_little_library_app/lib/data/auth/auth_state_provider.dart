import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

/// ──────────────────────────────────────────────────────────────────────────
/// AuthState — sealed union representing authentication state
/// ──────────────────────────────────────────────────────────────────────────

/// Represents the current authentication state of the app.
///
/// Three possible states:
/// - [AuthSignedIn] — user is authenticated; sync is enabled.
/// - [AuthSignedOut] — user is not authenticated; data is local-only.
/// - [AuthSkipped] — user chose offline-only mode; sync is disabled.
///
/// Each state exposes a [semanticLabel] for TalkBack / accessibility.
sealed class AuthState {
  const AuthState();

  /// Human-readable label for accessibility announcements.
  String get semanticLabel;
}

/// User is signed in with a valid [GoogleSignInAccount].
class AuthSignedIn extends AuthState {
  final GoogleSignInAccount account;

  const AuthSignedIn(this.account);

  /// Display name from the Google account.
  String? get displayName => account.displayName;

  /// Email from the Google account.
  String? get email => account.email;

  @override
  String get semanticLabel =>
      'Signed in as ${account.displayName ?? account.email}. Sync enabled.';
}

/// User is signed out — no Google account linked.
class AuthSignedOut extends AuthState {
  const AuthSignedOut();

  @override
  String get semanticLabel => 'Signed out. Sign in to enable sync.';
}

/// User chose to skip sign-in and use offline-only mode.
class AuthSkipped extends AuthState {
  const AuthSkipped();

  @override
  String get semanticLabel => 'Offline mode. Sign in to enable sync.';
}

/// ──────────────────────────────────────────────────────────────────────────
/// Providers
/// ──────────────────────────────────────────────────────────────────────────

/// Provider for the [GoogleSignIn] singleton.
///
/// Override in tests with a [MockGoogleSignIn].
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

/// Provider for [AuthService].
///
/// Must be overridden in tests via [ProviderScope.overrides].
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError(
    'authServiceProvider must be overridden in ProviderScope. '
    'Provide AuthService(googleSignIn: ..., prefs: ...).',
  );
});

/// Whether sync features are available (user is signed in).
final isSyncEnabledProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState is AuthSignedIn;
});

/// Manages [AuthState] transitions in response to sign-in, sign-out,
/// and skip actions.
///
/// On creation, automatically attempts to restore a previous session
/// via [AuthService.init]. The initial state is [AuthSignedOut],
/// transitioning to [AuthSignedIn] on successful restore.
class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Schedule async session restore after the provider is created.
    // We use Future.microtask to ensure the provider is fully built
    // before attempting async work.
    Future.microtask(_restoreSession);
    return const AuthSignedOut();
  }

  Future<void> _restoreSession() async {
    final authService = ref.read(authServiceProvider);
    await authService.restoreSession();
    final account = authService.account;
    if (account != null) {
      state = AuthSignedIn(account);
    }
  }

  /// Initiate Google Sign-In.
  ///
  /// On success, emits [AuthSignedIn] with the returned account.
  /// On failure or cancellation, stays in the current state.
  Future<void> signIn() async {
    final authService = ref.read(authServiceProvider);
    final account = await authService.signIn();
    if (account != null) {
      state = AuthSignedIn(account);
    }
  }

  /// Sign out and clear all auth state.
  ///
  /// Emits [AuthSignedOut]. Does not touch the local SQLite database.
  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    state = const AuthSignedOut();
  }

  /// Skip sign-in and enter offline-only mode.
  ///
  /// Emits [AuthSkipped]. Local CRUD operations remain available.
  /// Sync features are disabled.
  void skip() {
    state = const AuthSkipped();
  }

  /// Restore a previous session on app restart.
  ///
  /// Attempts silent sign-in using persisted credentials.
  Future<void> restoreSession() async {
    final authService = ref.read(authServiceProvider);
    await authService.restoreSession();
    final account = authService.account;
    if (account != null) {
      state = AuthSignedIn(account);
    } else {
      state = const AuthSignedOut();
    }
  }

  /// Refresh the auth token silently.
  ///
  /// Used before Drive API calls to ensure a fresh token.
  /// Returns `true` if successful.
  Future<bool> refreshToken() async {
    final authService = ref.read(authServiceProvider);
    final account = await authService.refreshToken();
    if (account != null) {
      state = AuthSignedIn(account);
      return true;
    }
    return false;
  }
}

/// Riverpod provider for [AuthState].
///
/// Initial state is [AuthSignedOut]. Automatically attempts to restore
/// a previous session on creation.
///
/// ### Usage
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// // ...
/// ref.read(authStateProvider.notifier).signIn();
/// ```
final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(
  AuthStateNotifier.new,
);
