// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider = WishlistRepositoryProvider._();

final class WishlistRepositoryProvider
    extends
        $FunctionalProvider<
          WishlistRepository,
          WishlistRepository,
          WishlistRepository
        >
    with $Provider<WishlistRepository> {
  WishlistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistRepositoryHash();

  @$internal
  @override
  $ProviderElement<WishlistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistRepository create(Ref ref) {
    return wishlistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistRepository>(value),
    );
  }
}

String _$wishlistRepositoryHash() =>
    r'74c7f87ffb5970abcce7e44c750127183a440794';

/// Real-time global wishlist stream (all items for the unlocked user).

@ProviderFor(wishlistItems)
final wishlistItemsProvider = WishlistItemsProvider._();

/// Real-time global wishlist stream (all items for the unlocked user).

final class WishlistItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WishlistItem>>,
          List<WishlistItem>,
          Stream<List<WishlistItem>>
        >
    with
        $FutureModifier<List<WishlistItem>>,
        $StreamProvider<List<WishlistItem>> {
  /// Real-time global wishlist stream (all items for the unlocked user).
  WishlistItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<WishlistItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WishlistItem>> create(Ref ref) {
    return wishlistItems(ref);
  }
}

String _$wishlistItemsHash() => r'fde1746284111832347b1f5d50be41ab52a8ca3f';

/// Write helpers for Wish List (add / rename / delete) — no priority/calendar.

@ProviderFor(WishlistActions)
final wishlistActionsProvider = WishlistActionsProvider._();

/// Write helpers for Wish List (add / rename / delete) — no priority/calendar.
final class WishlistActionsProvider
    extends $NotifierProvider<WishlistActions, void> {
  /// Write helpers for Wish List (add / rename / delete) — no priority/calendar.
  WishlistActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistActionsHash();

  @$internal
  @override
  WishlistActions create() => WishlistActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$wishlistActionsHash() => r'f9f98819cb3f269473bca80bb05c8deb08bfe63f';

/// Write helpers for Wish List (add / rename / delete) — no priority/calendar.

abstract class _$WishlistActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
