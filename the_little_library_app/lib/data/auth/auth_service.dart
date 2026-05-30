import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for persisting auth state across app restarts.
const String kPrefKeyAuthEmail = 'auth_email';
const String kPrefKeyAuthDisplayName = 'auth_display_name';

/// Wraps [GoogleSignIn] for OAuth authentication and token management.
///
/// Handles sign-in, sign-out, silent token refresh, and persistence
/// of account credentials via [SharedPreferences] for automatic
/// sign-in on app restart.
///
/// US-1.4.1 through US-1.4.17.
class AuthService {
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _prefs;

  GoogleSignInAccount? _account;

  AuthService({
    required GoogleSignIn googleSignIn,
    required SharedPreferences prefs,
  })  : _googleSignIn = googleSignIn,
        _prefs = prefs;

  // ──────────────────────────────────────────────────────────────────────────
  // Public accessors
  // ──────────────────────────────────────────────────────────────────────────

  /// The currently signed-in [GoogleSignInAccount], or `null`.
  GoogleSignInAccount? get account => _account;

  /// Display name of the signed-in user for UI rendering.
  String? get displayName => _account?.displayName;

  /// Email of the signed-in user, used as [deviceUser] on write operations.
  String? get email => _account?.email;

  /// Convenience getter for change-log [deviceUser] field.
  String? get deviceUser => email;

  /// Whether a user is currently signed in.
  bool isSignedIn() => _account != null;

  // ──────────────────────────────────────────────────────────────────────────
  // Sign-in / sign-out
  // ──────────────────────────────────────────────────────────────────────────

  /// Initiate the Google Sign-In OAuth flow.
  ///
  /// Calls [GoogleSignIn.authenticate] for an interactive sign-in.
  /// Returns the [GoogleSignInAccount] on success.
  /// Returns `null` on cancellation or recoverable failure
  /// (e.g. network error, [PlatformException] when Google Play Services
  /// are unavailable).
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (_) {
      // User cancelled, interrupted, or a non-fatal platform error.
      _account = null;
    } on PlatformException {
      _account = null;
    } on SocketException {
      _account = null;
    }

    if (_account != null) {
      await _persistAccount(_account!);
    }
    return _account;
  }

  /// Sign out the current user.
  ///
  /// Calls [GoogleSignIn.signOut], clears persisted auth data from
  /// [SharedPreferences], and sets the internal account to `null`.
  /// Does **not** touch the local SQLite database.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _clearPersistedAccount();
    _account = null;
  }

  /// Enter offline-only mode.
  ///
  /// This is a no-op at the service layer — the state provider
  /// transitions to `AuthSkipped` independently.
  void skip() {
    // No-op: state transition handled by the provider.
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Session persistence & restoration
  // ──────────────────────────────────────────────────────────────────────────

  /// Initialise the service on app start.
  ///
  /// Reads persisted credentials from [SharedPreferences] and attempts
  /// a silent sign-in via [GoogleSignIn.attemptLightweightAuthentication].
  /// If the stored token is invalid or the attempt fails, credentials
  /// are cleared and `_account` stays `null`.
  Future<void> init() async {
    final hasStoredAccount = _prefs.containsKey(kPrefKeyAuthEmail);
    if (!hasStoredAccount) return;

    _account = await _silentSignIn();
    if (_account == null) {
      // Stored token is no longer valid.
      await _clearPersistedAccount();
    }
  }

  /// Restore a previous session from [SharedPreferences].
  ///
  /// Alias for [init] provided for semantic clarity.
  Future<void> restoreSession() async {
    await init();
  }

  /// Perform a silent token refresh.
  ///
  /// Calls [GoogleSignIn.attemptLightweightAuthentication] to obtain
  /// a fresh token without user interaction. Called before Drive API
  /// calls to ensure a valid auth token.
  ///
  /// Returns the account if successful, `null` otherwise.
  Future<GoogleSignInAccount?> refreshToken() async {
    _account = await _silentSignIn();
    if (_account != null) {
      await _persistAccount(_account!);
    }
    return _account;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Attempt a silent sign-in using the platform's lightweight auth.
  ///
  /// On some platforms [attemptLightweightAuthentication] returns `null`
  /// (meaning the platform doesn't support returning a Future and the
  /// caller must listen to [GoogleSignIn.authenticationEvents] instead).
  /// In that case, this method returns `null` to indicate no account.
  Future<GoogleSignInAccount?> _silentSignIn() async {
    final future = _googleSignIn.attemptLightweightAuthentication();
    if (future == null) {
      // Platform streams events instead of returning a Future.
      return null;
    }
    try {
      return await future;
    } on GoogleSignInException {
      return null;
    }
  }

  Future<void> _persistAccount(GoogleSignInAccount account) async {
    await _prefs.setString(kPrefKeyAuthEmail, account.email);
    await _prefs.setString(
      kPrefKeyAuthDisplayName,
      account.displayName ?? '',
    );
  }

  Future<void> _clearPersistedAccount() async {
    await _prefs.remove(kPrefKeyAuthEmail);
    await _prefs.remove(kPrefKeyAuthDisplayName);
  }
}
