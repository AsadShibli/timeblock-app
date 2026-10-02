// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brain_dump_day_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Brain Dump visible day. Defaults to [planningDayFor]; Execution is unchanged.

@ProviderFor(BrainDumpDay)
final brainDumpDayProvider = BrainDumpDayProvider._();

/// Brain Dump visible day. Defaults to [planningDayFor]; Execution is unchanged.
final class BrainDumpDayProvider
    extends $NotifierProvider<BrainDumpDay, DateTime> {
  /// Brain Dump visible day. Defaults to [planningDayFor]; Execution is unchanged.
  BrainDumpDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brainDumpDayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brainDumpDayHash();

  @$internal
  @override
  BrainDumpDay create() => BrainDumpDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$brainDumpDayHash() => r'brainDumpDayManualGen001';

/// Brain Dump visible day. Defaults to [planningDayFor]; Execution is unchanged.

abstract class _$BrainDumpDay extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
