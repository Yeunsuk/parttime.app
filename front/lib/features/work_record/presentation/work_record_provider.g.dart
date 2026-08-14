// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkStatus)
final workStatusProvider = WorkStatusProvider._();

final class WorkStatusProvider
    extends $AsyncNotifierProvider<WorkStatus, WorkStatusModel> {
  WorkStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workStatusHash();

  @$internal
  @override
  WorkStatus create() => WorkStatus();
}

String _$workStatusHash() => r'86a01a9543343e59a5762cdc1c53b1b4541f433d';

abstract class _$WorkStatus extends $AsyncNotifier<WorkStatusModel> {
  FutureOr<WorkStatusModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WorkStatusModel>, WorkStatusModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WorkStatusModel>, WorkStatusModel>,
              AsyncValue<WorkStatusModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(calendar)
final calendarProvider = CalendarFamily._();

final class CalendarProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkRecordModel>>,
          List<WorkRecordModel>,
          FutureOr<List<WorkRecordModel>>
        >
    with
        $FutureModifier<List<WorkRecordModel>>,
        $FutureProvider<List<WorkRecordModel>> {
  CalendarProvider._({
    required CalendarFamily super.from,
    required CalendarParam super.argument,
  }) : super(
         retry: null,
         name: r'calendarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarHash();

  @override
  String toString() {
    return r'calendarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkRecordModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkRecordModel>> create(Ref ref) {
    final argument = this.argument as CalendarParam;
    return calendar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarHash() => r'f27019e309e7604eb695c98494941eba3f4c4ec3';

final class CalendarFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<WorkRecordModel>>,
          CalendarParam
        > {
  CalendarFamily._()
    : super(
        retry: null,
        name: r'calendarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarProvider call(CalendarParam param) =>
      CalendarProvider._(argument: param, from: this);

  @override
  String toString() => r'calendarProvider';
}
