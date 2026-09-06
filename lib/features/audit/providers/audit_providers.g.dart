// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(auditRepository)
final auditRepositoryProvider = AuditRepositoryProvider._();

final class AuditRepositoryProvider
    extends
        $FunctionalProvider<AuditRepository, AuditRepository, AuditRepository>
    with $Provider<AuditRepository> {
  AuditRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuditRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuditRepository create(Ref ref) {
    return auditRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditRepository>(value),
    );
  }
}

String _$auditRepositoryHash() => r'639b13ecb6de71027780dcc57ccef7f6d55fd344';

/// Real-time Audit items for the unlocked user.

@ProviderFor(auditItems)
final auditItemsProvider = AuditItemsProvider._();

/// Real-time Audit items for the unlocked user.

final class AuditItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditItem>>,
          List<AuditItem>,
          Stream<List<AuditItem>>
        >
    with $FutureModifier<List<AuditItem>>, $StreamProvider<List<AuditItem>> {
  /// Real-time Audit items for the unlocked user.
  AuditItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<AuditItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AuditItem>> create(Ref ref) {
    return auditItems(ref);
  }
}

String _$auditItemsHash() => r'1e3a8c2fe25d96b1be3f9ffdc88bed083f7830e5';

/// Write helpers for Audit (add / update / delete).

@ProviderFor(AuditActions)
final auditActionsProvider = AuditActionsProvider._();

/// Write helpers for Audit (add / update / delete).
final class AuditActionsProvider extends $NotifierProvider<AuditActions, void> {
  /// Write helpers for Audit (add / update / delete).
  AuditActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditActionsHash();

  @$internal
  @override
  AuditActions create() => AuditActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$auditActionsHash() => r'7070c64489419315fa7b8ac18069e4e61e67ff34';

/// Write helpers for Audit (add / update / delete).

abstract class _$AuditActions extends $Notifier<void> {
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
