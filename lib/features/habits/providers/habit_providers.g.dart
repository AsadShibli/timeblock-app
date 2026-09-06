// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitRepository)
final habitRepositoryProvider = HabitRepositoryProvider._();

final class HabitRepositoryProvider
    extends
        $FunctionalProvider<HabitRepository, HabitRepository, HabitRepository>
    with $Provider<HabitRepository> {
  HabitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HabitRepository create(Ref ref) {
    return habitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitRepository>(value),
    );
  }
}

String _$habitRepositoryHash() => r'458211773b9ff20f5f40b443f756730bed32ccbc';

@ProviderFor(habitDefinitions)
final habitDefinitionsProvider = HabitDefinitionsProvider._();

final class HabitDefinitionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitDefinition>>,
          List<HabitDefinition>,
          Stream<List<HabitDefinition>>
        >
    with
        $FutureModifier<List<HabitDefinition>>,
        $StreamProvider<List<HabitDefinition>> {
  HabitDefinitionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitDefinitionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitDefinitionsHash();

  @$internal
  @override
  $StreamProviderElement<List<HabitDefinition>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitDefinition>> create(Ref ref) {
    return habitDefinitions(ref);
  }
}

String _$habitDefinitionsHash() => r'e805b0d9b030bcbd5fe45279c197d80638a74987';

@ProviderFor(todaysHabitLogs)
final todaysHabitLogsProvider = TodaysHabitLogsProvider._();

final class TodaysHabitLogsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitLog>>,
          List<HabitLog>,
          Stream<List<HabitLog>>
        >
    with $FutureModifier<List<HabitLog>>, $StreamProvider<List<HabitLog>> {
  TodaysHabitLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysHabitLogsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysHabitLogsHash();

  @$internal
  @override
  $StreamProviderElement<List<HabitLog>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<HabitLog>> create(Ref ref) {
    return todaysHabitLogs(ref);
  }
}

String _$todaysHabitLogsHash() => r'666c78ffe1dd49998733b165d1ae0b03a491df54';

/// Combines definitions + today's logs into UI rows (instant stream updates).

@ProviderFor(todaysHabits)
final todaysHabitsProvider = TodaysHabitsProvider._();

/// Combines definitions + today's logs into UI rows (instant stream updates).

final class TodaysHabitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HabitRow>>,
          AsyncValue<List<HabitRow>>,
          AsyncValue<List<HabitRow>>
        >
    with $Provider<AsyncValue<List<HabitRow>>> {
  /// Combines definitions + today's logs into UI rows (instant stream updates).
  TodaysHabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysHabitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysHabitsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<HabitRow>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<HabitRow>> create(Ref ref) {
    return todaysHabits(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<HabitRow>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<HabitRow>>>(value),
    );
  }
}

String _$todaysHabitsHash() => r'68a516fa11afcfdd5ed60fc91075f82502a6b737';

@ProviderFor(HabitActions)
final habitActionsProvider = HabitActionsProvider._();

final class HabitActionsProvider extends $NotifierProvider<HabitActions, void> {
  HabitActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitActionsHash();

  @$internal
  @override
  HabitActions create() => HabitActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$habitActionsHash() => r'7fbb56cd93caaecc8ad7b4c5d2655b78d3ad0dd2';

abstract class _$HabitActions extends $Notifier<void> {
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
