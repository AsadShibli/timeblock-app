// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRepository)
final eventRepositoryProvider = EventRepositoryProvider._();

final class EventRepositoryProvider
    extends
        $FunctionalProvider<EventRepository, EventRepository, EventRepository>
    with $Provider<EventRepository> {
  EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventRepository create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventRepository>(value),
    );
  }
}

String _$eventRepositoryHash() => r'f1672c46054f0f0b78a6aad4aaed84bec026b6e6';

/// Real-time time blocks for a day. [dateKey] format: yyyy-MM-dd.

@ProviderFor(dailyEvents)
final dailyEventsProvider = DailyEventsFamily._();

/// Real-time time blocks for a day. [dateKey] format: yyyy-MM-dd.

final class DailyEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyEvent>>,
          List<DailyEvent>,
          Stream<List<DailyEvent>>
        >
    with $FutureModifier<List<DailyEvent>>, $StreamProvider<List<DailyEvent>> {
  /// Real-time time blocks for a day. [dateKey] format: yyyy-MM-dd.
  DailyEventsProvider._({
    required DailyEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dailyEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailyEventsHash();

  @override
  String toString() {
    return r'dailyEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<DailyEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DailyEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return dailyEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailyEventsHash() => r'2bd39b1d4b77a2580dfdf9153ba311034c462464';

/// Real-time time blocks for a day. [dateKey] format: yyyy-MM-dd.

final class DailyEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<DailyEvent>>, String> {
  DailyEventsFamily._()
    : super(
        retry: null,
        name: r'dailyEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Real-time time blocks for a day. [dateKey] format: yyyy-MM-dd.

  DailyEventsProvider call(String dateKey) =>
      DailyEventsProvider._(argument: dateKey, from: this);

  @override
  String toString() => r'dailyEventsProvider';
}

/// Write helpers for calendar events (create / move-resize / delete).

@ProviderFor(EventActions)
final eventActionsProvider = EventActionsProvider._();

/// Write helpers for calendar events (create / move-resize / delete).
final class EventActionsProvider extends $NotifierProvider<EventActions, void> {
  /// Write helpers for calendar events (create / move-resize / delete).
  EventActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventActionsHash();

  @$internal
  @override
  EventActions create() => EventActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$eventActionsHash() => r'1f52d0a3a93cf9bff6360ef8fe885861e18983d1';

/// Write helpers for calendar events (create / move-resize / delete).

abstract class _$EventActions extends $Notifier<void> {
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
