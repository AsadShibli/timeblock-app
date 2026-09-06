// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_day_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared "today" (local) for Brain Dump + Execution tabs.

@ProviderFor(SelectedDay)
final selectedDayProvider = SelectedDayProvider._();

/// Shared "today" (local) for Brain Dump + Execution tabs.
final class SelectedDayProvider
    extends $NotifierProvider<SelectedDay, DateTime> {
  /// Shared "today" (local) for Brain Dump + Execution tabs.
  SelectedDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDayHash();

  @$internal
  @override
  SelectedDay create() => SelectedDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDayHash() => r'8415d35a46a0a2b9a97b39710a9631015bb2342d';

/// Shared "today" (local) for Brain Dump + Execution tabs.

abstract class _$SelectedDay extends $Notifier<DateTime> {
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
