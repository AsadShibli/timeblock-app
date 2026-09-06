// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the PIN auth repository (singleton for the app lifetime).

@ProviderFor(pinAuthRepository)
final pinAuthRepositoryProvider = PinAuthRepositoryProvider._();

/// Provides the PIN auth repository (singleton for the app lifetime).

final class PinAuthRepositoryProvider
    extends
        $FunctionalProvider<
          PinAuthRepository,
          PinAuthRepository,
          PinAuthRepository
        >
    with $Provider<PinAuthRepository> {
  /// Provides the PIN auth repository (singleton for the app lifetime).
  PinAuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinAuthRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinAuthRepositoryHash();

  @$internal
  @override
  $ProviderElement<PinAuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PinAuthRepository create(Ref ref) {
    return pinAuthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinAuthRepository>(value),
    );
  }
}

String _$pinAuthRepositoryHash() => r'f794dffa6d00b5b27f02030904b857bb2961b8d2';

/// Holds the resolved profile UID after a successful 3-char PIN login.
/// null = locked / not authenticated.

@ProviderFor(AuthSession)
final authSessionProvider = AuthSessionProvider._();

/// Holds the resolved profile UID after a successful 3-char PIN login.
/// null = locked / not authenticated.
final class AuthSessionProvider
    extends $NotifierProvider<AuthSession, String?> {
  /// Holds the resolved profile UID after a successful 3-char PIN login.
  /// null = locked / not authenticated.
  AuthSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionHash();

  @$internal
  @override
  AuthSession create() => AuthSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$authSessionHash() => r'a840180b85cdb35667f00dc532c729e15818a041';

/// Holds the resolved profile UID after a successful 3-char PIN login.
/// null = locked / not authenticated.

abstract class _$AuthSession extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
