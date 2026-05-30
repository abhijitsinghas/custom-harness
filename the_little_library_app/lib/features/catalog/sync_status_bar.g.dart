// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for sync status state.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `syncStatusNotifierProvider`.

@ProviderFor(SyncStatusNotifier)
final syncStatusProvider = SyncStatusNotifierProvider._();

/// Riverpod provider for sync status state.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `syncStatusNotifierProvider`.
final class SyncStatusNotifierProvider
    extends $NotifierProvider<SyncStatusNotifier, SyncStatus> {
  /// Riverpod provider for sync status state.
  ///
  /// Uses [riverpod_annotation] code generation; the provider
  /// is named `syncStatusNotifierProvider`.
  SyncStatusNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncStatusNotifierHash();

  @$internal
  @override
  SyncStatusNotifier create() => SyncStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStatusNotifierHash() =>
    r'2b7a82c94e6b2d318038f4e3c2e8276e67652bbd';

/// Riverpod provider for sync status state.
///
/// Uses [riverpod_annotation] code generation; the provider
/// is named `syncStatusNotifierProvider`.

abstract class _$SyncStatusNotifier extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncStatus, SyncStatus>, SyncStatus, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
