// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persisted theme mode — defaults to system.
///
/// Reads the persisted [ThemeMode] from [SharedPreferences] on build.
/// Writes back on every toggle/set to persist across app restarts.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `themeModeProvider`.

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// Persisted theme mode — defaults to system.
///
/// Reads the persisted [ThemeMode] from [SharedPreferences] on build.
/// Writes back on every toggle/set to persist across app restarts.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `themeModeProvider`.
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// Persisted theme mode — defaults to system.
  ///
  /// Reads the persisted [ThemeMode] from [SharedPreferences] on build.
  /// Writes back on every toggle/set to persist across app restarts.
  ///
  /// Uses [riverpod_annotation] code generation; the provider
  /// is named `themeModeProvider`.
  ThemeModeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'49d129bbcbcd3358214624e39d0c9babdeb95d61';

/// Persisted theme mode — defaults to system.
///
/// Reads the persisted [ThemeMode] from [SharedPreferences] on build.
/// Writes back on every toggle/set to persist across app restarts.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `themeModeProvider`.

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ThemeMode, ThemeMode>, ThemeMode, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
