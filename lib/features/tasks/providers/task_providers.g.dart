// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends $FunctionalProvider<TaskRepository, TaskRepository, TaskRepository>
    with $Provider<TaskRepository> {
  TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'869b99b09e8de14e170eabc91bd28607aed7c33c';

/// Real-time tasks for a day. [dateKey] format: yyyy-MM-dd.

@ProviderFor(dailyTasks)
final dailyTasksProvider = DailyTasksFamily._();

/// Real-time tasks for a day. [dateKey] format: yyyy-MM-dd.

final class DailyTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyTask>>,
          List<DailyTask>,
          Stream<List<DailyTask>>
        >
    with $FutureModifier<List<DailyTask>>, $StreamProvider<List<DailyTask>> {
  /// Real-time tasks for a day. [dateKey] format: yyyy-MM-dd.
  DailyTasksProvider._({
    required DailyTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dailyTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyTasksHash();

  @override
  String toString() {
    return r'dailyTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<DailyTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailyTask>> create(Ref ref) {
    final argument = this.argument as String;
    return dailyTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyTasksHash() => r'f0cd22e92ef20e7f8e45c9a4b1370002c7cba17d';

/// Real-time tasks for a day. [dateKey] format: yyyy-MM-dd.

final class DailyTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<DailyTask>>, String> {
  DailyTasksFamily._()
    : super(
        retry: null,
        name: r'dailyTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Real-time tasks for a day. [dateKey] format: yyyy-MM-dd.

  DailyTasksProvider call(String dateKey) =>
      DailyTasksProvider._(argument: dateKey, from: this);

  @override
  String toString() => r'dailyTasksProvider';
}

/// Priority-only tasks for the calendar bottom sheet.

@ProviderFor(priorityTasks)
final priorityTasksProvider = PriorityTasksFamily._();

/// Priority-only tasks for the calendar bottom sheet.

final class PriorityTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyTask>>,
          List<DailyTask>,
          Stream<List<DailyTask>>
        >
    with $FutureModifier<List<DailyTask>>, $StreamProvider<List<DailyTask>> {
  /// Priority-only tasks for the calendar bottom sheet.
  PriorityTasksProvider._({
    required PriorityTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'priorityTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$priorityTasksHash();

  @override
  String toString() {
    return r'priorityTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<DailyTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailyTask>> create(Ref ref) {
    final argument = this.argument as String;
    return priorityTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PriorityTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$priorityTasksHash() => r'88cf60683daca48d4cd4146bc86157e8aad11abf';

/// Priority-only tasks for the calendar bottom sheet.

final class PriorityTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<DailyTask>>, String> {
  PriorityTasksFamily._()
    : super(
        retry: null,
        name: r'priorityTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Priority-only tasks for the calendar bottom sheet.

  PriorityTasksProvider call(String dateKey) =>
      PriorityTasksProvider._(argument: dateKey, from: this);

  @override
  String toString() => r'priorityTasksProvider';
}

/// Write helpers for tasks (create / toggle / delete).

@ProviderFor(TaskActions)
final taskActionsProvider = TaskActionsProvider._();

/// Write helpers for tasks (create / toggle / delete).
final class TaskActionsProvider extends $NotifierProvider<TaskActions, void> {
  /// Write helpers for tasks (create / toggle / delete).
  TaskActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskActionsHash();

  @$internal
  @override
  TaskActions create() => TaskActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$taskActionsHash() => r'ab5f1876aa7ae436f46016493e5dea1484395e96';

/// Write helpers for tasks (create / toggle / delete).

abstract class _$TaskActions extends $Notifier<void> {
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
